# EKS Worker Nodes Resources


resource "aws_iam_role" "node_policy" {
  name = var.node_policy_name
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "auto_scalar_access" {
  name = var.auto_scalar_access

  policy = jsonencode(
    {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Sid": "clusterAutoscalerAll",
              "Effect": "Allow",
              "Action": [
                  "ec2:DescribeLaunchTemplateVersions",
                  "autoscaling:DescribeTags",
                  "autoscaling:DescribeLaunchConfigurations",
                  "autoscaling:DescribeAutoScalingInstances",
                  "autoscaling:DescribeAutoScalingGroups"
              ],
              "Resource": "*"
          },
          {
              "Sid": "clusterAutoscalerOwn",
              "Effect": "Allow",
              "Action": [
                  "autoscaling:UpdateAutoScalingGroup",
                  "autoscaling:TerminateInstanceInAutoScalingGroup",
                  "autoscaling:SetDesiredCapacity"
              ],
              "Resource": "*",
              "Condition": {
                  "StringEquals": {
                      "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled": [
                          "true"
                      ],
                      "autoscaling:ResourceTag/kubernetes.io/cluster/${var.cluster_name}": [
                          "owned"
                      ]
                  }
              }
          }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "demo-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_policy.name
}

resource "aws_iam_role_policy_attachment" "demo-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_policy.name
}

resource "aws_iam_role_policy_attachment" "demo-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_policy.name
}




resource "aws_eks_node_group" "node-group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.node_policy.arn
  subnet_ids = ["subnet-<id>", "subnet-<id>", "subnet-<id>"]
  tags = merge(
    var.tags,
    {
      "Name": var.node_group_name,
      "k8s.io/cluster-autoscaler/enabled": "owned",
      "k8s.io/cluster-autoscaler/${var.cluster_name}": "true",
      "kubernetes.io/cluster/${var.cluster_name}": "owned",
      "k8s.io/cluster/${var.cluster_name}": "owned",
      "efs.csi.aws.com/cluster": "true"
    }
  )

  scaling_config {
    desired_size = var.scaling_config.desired_size
    max_size     = var.scaling_config.max_size
    min_size     = var.scaling_config.min_size
  }
  
  remote_access { 
    ec2_ssh_key =  var.ssh_key_name
  } 
  
  instance_types    = var.node_instance_type
  disk_size         = var.node_instance_disk_size
  depends_on = [
    aws_iam_role_policy_attachment.demo-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.demo-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.demo-node-AmazonEC2ContainerRegistryReadOnly,
  ]
}
