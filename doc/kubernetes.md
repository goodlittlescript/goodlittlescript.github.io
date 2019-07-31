# kubernetes

Links:

* https://kubernetes.io/docs/home/

Suggestions:

Maybe skip the docs on day 1.  Like kubernetes itself the kubernetes docs are expansive and don't do a good job of getting you a good mental model.  There's loads of good stuff, but it is hard to see... they do too much and too little at the same time.  For example see the help for kubectl itself.

```bash
kubectl -h
# Basic Commands (Beginner):
#   ...
#
# Basic Commands (Intermediate):
#   ...
#
```

Beginner and Intermediate commands?  Later there is an "Advanced Commands".  This is a strong hint they are struggling to explain themselves.  Kubernetes has a porcelain vs plumbing problem.   It is plumbing.  The porcelain on it is useful, but hard to understand without the plumbing.

Ergo I recommend you do some targeted reflection to start.  Later read the docs for specific details.  Work your way back to the the "Beginner" commands.

## Reflection exercise

See the help.  Take a look at the get ("Intermediate") and apply ("Advanced") commands.

```bash
kubectl -h
kubectl get -h
kubectl apply -h
```

Note the kind of flags under get:

* --all-namespaces (suggests logical separations)
* --selector (suggest groups - in fact grouping by labels)
* --watch (suggests a feed of changes)

Note the kind of flags under apply:

* --dry-run (aka "this can be risky")
* --prune (aka "this is why this is risky")
* --prune-whitelist (aka "effort to mitigate risk")
* --selector (same as under get, implying a theme of grouping by labels)

Also take note of the last line in each help and go check out `kubectl options`.  Note the kind of options on that.

* --cluster, --context, --server (identifies kubectl as pointing to something)
* --user, --token (and we have to authenticate to it)
* --namespace (and then there are logical separations)
* -v (logging yay!)

In aggregate this establishes the beginning of a mental model.  The above indicate kubectl is pointed some "control" structure (the control plane / master nodes) and that within that there is a "logical" structure (--namespace, --all-namespaces) and within that there are things that are grouped and and classified (--selector).  

You don't see flags for the nodes where stuff actually runs. That too is a hint. The point of kubernetes is to give some kind of specification to the control structure, which then maps it into a logical structure.  In short kubernetes is a scheduler.

Now take a look at the cluster and observe the API you're using to talk to it.

```bash
kubectl cluster-info
# Kubernetes master is running at https://localhost:6443

kubectl -v=9 cluster-info
# ...
# I0730 09:15:33.786679   36729 round_trippers.go:386] curl -k -v -XGET  -H "Accept: application/json, */*" -H "User-Agent: kubectl/v1.12.0 (darwin/amd64) kubernetes/0ed3388" 'https://localhost:6443/api/v1/namespaces/kube-system/services?labelSelector=kubernetes.io%2Fcluster-service%3Dtrue'
# ...
# I0730 09:15:33.801870   36729 request.go:942] Response Body: {"kind":"ServiceList",...
# Kubernetes master is running at https://localhost:6443
# KubeDNS is running at https://localhost:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

curl -k -v -XGET  -H "Accept: application/json, */*" -H "User-Agent: kubectl/v1.12.0 (darwin/amd64) kubernetes/0ed3388" 'https://localhost:6443/api/v1/namespaces/kube-system/services?labelSelector=kubernetes.io%2Fcluster-service%3Dtrue' | jq .
# {
#   "kind": "Status",
#   "apiVersion": "v1",
#   "metadata": {},
#   "status": "Failure",
#   "message": "services is forbidden: User \"system:anonymous\" cannot list services in the namespace \"kube-system\"",
#   "reason": "Forbidden",
#   "details": {
#     "kind": "services"
#   },
#   "code": 403
# }
```

Some kind of auth is going on here.  The details don't matter at this point because kubernetes provides a way around it; a proxy that adds your auth for you.

```bash
kubectl proxy
# Starting to serve on 127.0.0.1:8001
```

Now go hit the proxy using http.

```bash
curl -k -v -XGET  -H "Accept: application/json, */*" -H "User-Agent: kubectl/v1.12.0 (darwin/amd64) kubernetes/0ed3388" 'http://localhost:8001/api/v1/namespaces/kube-system/services?labelSelector=kubernetes.io%2Fcluster-service%3Dtrue' | jq .
# {
#   "kind": "ServiceList",
#   "apiVersion": "v1",
#   "metadata": {
#     "selfLink": "/api/v1/namespaces/kube-system/services",
#     "resourceVersion": "1231721"
#   },
#   "items": [
# ...
```

Observe that this ultimately is a REST api.  All commands tie back to some url.

```bash
kubectl api-resources
kubectl api-resources -v=9 2>&1 | grep GET

kubectl api-versions
kubectl api-versions -v=9 2>&1 | grep GET

kubectl get namespaces
kubectl get namespaces -v=9 2>&1 | grep GET

kubectl get pods
kubectl get pods --all-namespaces -v=9 2>&1 | grep GET
```

Knowing this sets up the mental model to take into learning kubernetes.  The idea is to create loosely-coupled resource definitions (POST JSON blobs) that the control plane needs to translate into real resources in the cluster.  AKA there will be urls and JSON request/response bodies.

## Basic Workflow

Define resources to describe what you want.  Apply them as a group, at once, so that anything left out can be pruned.

All resources have this core shape:

```
apiVersion: ""    // required - one of `api-versions`, is base of REST url
kind: ""          // required - one of `api-resources`, suffix of REST url
metadata:
  name: ""        // required - must be unique per kind
  namespace: ""   // optional - defaults to current context
  labels: {}      // optional - used to for selection, has restrictions
  annotations: {} // optional - tracking info and stuff, generally unrestricted
spec: {}          // one-of - the definition of the resource
data: {}          // one-of - the data of the resource
items: []         // one-of - occurs in List resources
status: {}        // added by kubernetes
```

This is a good structure.  The apiVersion and kind route these objects to a handler, there is unstructured and structured design space.  The status part is excellent from an implementer standpoint too -- a standard place to save information.

Due to the structure kubernetes can look at the data and know "this is new" or "this has changed".  As a result a group of resources definitions can be applied at once, which enables unspecified things to be identified as unwanted and pruned. It is a "declarative" way of managing resource (the "Advanced" way of managing things - a do-this-do-that "imperative" approach is the "Beginner" way).

To reiterate - the idea is to define resources to describe what you want.  Apply them as a group, at once, so that anything left out can be pruned.  How do?

## Apply a group of resource definitions

Resource definitions can be fed to `kubectl apply` as stream of JSON objects, or they can be formed into a List resource, or (in recent versions) you can group them into files in a directory and provide that.  YAML is an alternate way to specify the JSON.  The metaphor is a stream so you can organize as you like.

```bash
cat resource.json resource.yml | kubectl apply -f -
kubectl apply -f resource.json
kubectl apply -k resources_dir
```

_Sidebar: kubectl apply does not have a good command line design... `-f` could easily be a list of files and if it were then neither `-f` nor `-k` would be needed. IMO it suggests the culture of the developers.  Kubernetes seems designed with web sensibilities and kubectl nails web things, and could be command line friendly, but isn't._

```bash
# pretend the command signature was: kubectl apply [FILES...]
cat resource.json resource.yml | kubectl apply -
kubectl apply resource.json resource.yml
kubectl apply resources_dir/*
```

Resources are very verbose, so you will want to organize.  Also there's a problem - you need to line things up.  Imagine a kubernetes namespace as a bustling bazaar with independent people working in identifiable colors -- that is a cluster.  It is the way it works.

* With prune you use labels and selectors to limit what is in scope - get it wrong and you may delete lots of stuff.
* With services you need to use labels and selectors to pick which containers belong to the service.
* You need to associate configmaps/secrets to pods, at the very least needing name coordination.

This means you have to have a plan, then execute that plan by coordinating values in multiple places.  It is hard to do by hand.  Values may also vary by environment.  You need a template layer.  With high-minded shortsightedness, kubectl has intentionally not provided that so we have to.

The general plan then:

* Have a (name/label/annotation) plan
* Template to make a stream of resource definitions using the plan
* Apply with `kubectl apply --prune`
* Profit

_Sidebar: a google team achieved what the community could not, and convinced kubernetes to include [kustomize](https://kustomize.io/) into kubectl in recent versions -- they say it isn't templating but it amounts to the same thing.  It's a reasonable thing to imagine switching to it, especially when docker-for-mac updates._

## A Plan

Identify components made of related "kinds" of resources.  Connect with names to make units.   Pod + Configmap + Secret

Add [recommended labels](https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels) to group resources.


Add lifecycle labels to group resources according to when and what order they live in.  Ideally make your resources order-independent so these are non-existent.

Add [checksum annotations](https://github.com/helm/helm/blob/master/docs/charts_tips_and_tricks.md#automatically-roll-deployments-when-configmaps-or-secrets-change).  Ensure changes when linked things change, rolling deploy when needed.

## Templates

## Things


When you have a file with all your resources in it they call it a "manifest".  
