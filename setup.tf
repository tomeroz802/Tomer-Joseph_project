resource "terraform_data" "clusterConfigutration" {
  provisioner "local-exec" {
    command = "aws eks --region eu-west-3 update-kubeconfig --name eks-cluster"
  }
  depends_on = [aws_eks_cluster.eks-cluster  ]
}

resource "terraform_data" "installIngress" {
  provisioner "local-exec" {
    command = "kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/aws/deploy.yaml" 
  }
  depends_on = [aws_eks_addon.addons]
}


resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "3.35.4"
  values           = [file("values/argocd.yaml")]

  depends_on = [ terraform_data.installIngress]
}
# helm install argocd -n argocd -f values/argocd.yaml


resource "terraform_data" "ApplyIngress" {
  provisioner "local-exec" {
    command = "kubectl apply -f argo-ingress.yaml"
  }

  depends_on = [ helm_release.argocd ]
  
}

resource "aws_route53_zone" "primary" {
  name = "devops-prod.com"
}
