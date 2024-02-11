resource "terraform_data" "clusterConfigutration" {
  provisioner "local-exec" {
    command = "aws eks --region ap-northeast-3 update-kubeconfig --name eks-cluster"
  }
  depends_on = [aws_eks_cluster.eks-cluster  ]
}

resource "terraform_data" "installIngress" {
  provisioner "local-exec" {
    command = "kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/aws/deploy.yaml" 
  }
  depends_on = [aws_eks_addon.addons]
}

resource "terraform_data" "ns-cert-manager" {
  provisioner  "local-exec" {
    command = "kubectl create namespace cert-manager"
  }
  depends_on = [terraform_data.installIngress]
}


resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  namespace = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "issuer_email"
    value = "tomeroz802@gmail.com"
  }
  depends_on = [terraform_data.ns-cert-manager]
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

resource "aws_route53_zone" "primary" {
  name = "devops-prod.com"
}
