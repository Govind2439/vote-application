output "cluster_name" {
  value = aws_eks_cluster.eks.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "kubeconfig" {
  value = <<EOF
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.eks.endpoint}
    certificate-authority-data: ${base64decode(aws_eks_cluster.eks.certificate_authority.0.data)}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - ${aws_eks_cluster.eks.name}
EOF
}

output "voting_service_endpoint" {
  value = kubernetes_service.voting_service.status[0].load_balancer.ingress[0].hostname
}

output "result_service_endpoint" {
  value = kubernetes_service.result_service.status[0].load_balancer.ingress[0].hostname
}

