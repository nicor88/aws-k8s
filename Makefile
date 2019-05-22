CLUSTER = "nicor88-dev-k8s-cluster"

create-kube-config:
	aws eks update-kubeconfig --name $(CLUSTER) --kubeconfig ~/.kube/config_$(CLUSTER)
