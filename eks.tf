#
# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services
#  * EC2 Security Group to allow networking traffic with EKS cluster
#  * EKS Cluster
#

resource "aws_iam_role" "cluster_policy" {
  name = var.eks_cluster_policy_name

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "aura-prod-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_policy.name
}

resource "aws_iam_role_policy_attachment" "aura-prod-cluster-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster_policy.name
}


resource "aws_security_group" "cluster_security_group" {
  name        = "eks-cluster-sg-prod"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group_rule" "eks-cluster-ingress-https" {
  #   cidr_blocks       = [local.workstation-external-cidr]
  cidr_blocks       = [ "0.0.0.0/0" ]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.cluster_security_group.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster_policy.arn
 
  vpc_config {
    security_group_ids = [aws_security_group.cluster_security_group.id]
    subnet_ids = ["subnet-<id>", "subnet-<id>", "subnet-<id>"]
  }


  depends_on = [
    aws_iam_role_policy_attachment.aura-prod-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.aura-prod-cluster-AmazonEKSVPCResourceController,
  ]
}

