# Monitor K8S


## Deployment
<pre>
# enable kubectl profile
export KUBECONFIG=$HOME/.kube/config_$CLUSTER_NAME

# deploy monitoring
kubectl apply -f k8s-dashboard.yml
kubectl apply -f heapster.yml
kubectl apply -f heapster-rbac.yml
kubectl apply -f influxdb.yml
# the following 2 commands are needed to give the right permission to the dashboard
kubectl apply -f eks-admin-service-account.yml
kubectl apply -f eks-admin-cluster-role-binding.yml
</pre>

## Access the Dashboard
1. Retrieve an authentication token for the eks-admin service account. Copy the <authentication_token> value from the output. You use this token to connect to the dashboard.
	<pre>
	kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')
	</pre>
	Copy the token field.

2. Start the proxy
	<pre>
	kubectl proxy
	</pre>

3. Use this [link](http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/) to access the dashboard
