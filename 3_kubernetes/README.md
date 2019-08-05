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

Knowing this sets up the mental model to take into learning kubernetes.  The idea is to create loosely-coupled resource definitions (POST JSON blobs) that the control plane needs to translate into real resources (containers) on the nodes in the cluster.
