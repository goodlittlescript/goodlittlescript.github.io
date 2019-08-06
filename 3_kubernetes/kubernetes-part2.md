# kubernetes

## A Plan

1) Connect related resources by name to make components.

2) Add lifecycle labels to order the rollout of resources (ex to ensure the latest configs/secrets are available, or to make sure db migrations go before a server rollout).

3) Use namespaces to avoid further grouping (also important for secrets).

4) Use [checksum annotations](https://github.com/helm/helm/blob/master/docs/charts_tips_and_tricks.md#automatically-roll-deployments-when-configmaps-or-secrets-change) to ensure pod changes when configs/secrets change.

## Labels

Use labels to make groups and selectors to pick them.

```bash
kubectl apply -f timepod6.yml
kubectl get pods
kubectl get pods -l 'group=one'
kubectl get pods -l 'group=two'
kubectl get pods -l 'group in (one)'
kubectl get pods -l 'group in (one,two)'
```

Label selectors work in lots of places.

```bash
kubectl logs -l 'group in (one)'
kubectl delete pods -l 'group in (one)'
kubectl get pods
kubectl delete pods -l 'group in (one,two)'
kubectl get pods
```

Importantly labels work to select across a stream.  This is picking from an input list that we feed in.

```bash
kubectl apply -f timepod6.yml -l 'group in (one)'
kubectl get pods
kubectl apply -f timepod6.yml
kubectl delete -f timepod6.yml -l 'group in (one)'
kubectl get pods
```

It also works server side with whatever is existing.  The labels are scoping both sides of the equation before doing any create/update/prune activity (note you MUST pick `--all` or provide a selector for prune, so you have to do one of the following).

```bash
# prune without labels
kubectl apply -f timepod6.yml
kubectl get pods
kubectl apply -f timepod6a.yml --prune --all
kubectl get pods
kubectl delete pod --all

# prune with labels
kubectl apply -f timepod6.yml
kubectl get pods
kubectl apply -f timepod6a.yml --prune -l 'group in (one)'
kubectl get pods
kubectl delete pod --all
```

This is generic functionality that applies to all resources, and is fairly unavoidable in the prune way of managing resource (ie declarative), because `--all` is typically unacceptable. Reasons:

* Often there are natural groups you want to manage at the same time.  Ex your server components plus your shell components.  You wouldn't want creating one to destroy the other... instead it's nice to be like "make my shell", "now make my server", "now delete just my server".

* What kubectl puts into `--all` is often not what you want.  Some things like network policies are not included by default, but NAMESPACES ARE.  So if you don't list your namespace...

```
kubectl apply -f timepod5.yml
kubectl apply -f timepod6.yml --prune --all
# pod/timepod6-one-a created
# pod/timepod6-one-b created
# pod/timepod6-two-a created
# namespace/namespace5 pruned   # AAAAAHHHHARRGGGGHHHH!
```

What this implies pretty strongly is:

* Make a master list of all the things you care about.  More that one list is ok, but one master list is easiest.
* Add labels to make groups.
* Apply the master list using labels for the specific parts you care about.

BIG bonus is to use a service account that is scoped to a specific namespace so you don't accidentally destroy literally everything else in the cluster if you accidentally `--all` (either with the flag or by messing up the label scheme).
