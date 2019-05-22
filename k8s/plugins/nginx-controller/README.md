# ginx Ingress

## How to deploy
<pre>
# basic deployment
kubectl apply -f base.yaml

# layer 7
kubectl apply -f service-l7.yaml
kubectl apply -f service-l7-patch-configmap.yaml

</pre>
