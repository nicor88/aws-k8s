CLUSTER = "nicor88-dev-k8s-cluster"

create-kube-config:
	@aws eks update-kubeconfig --name $(CLUSTER) --kubeconfig ~/.kube/config_$(CLUSTER)

deploy-dashboard:
	@kubectl apply -f k8s/plugins/monitoring --recursive

deploy-autoscaler:
	@kubectl apply -f k8s/plugins/cluster-autoscaler.yml
