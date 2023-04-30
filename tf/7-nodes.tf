data "aws_iam_policy_document" "ec2-yellow-taxi-role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role" "yellow-taxi-nodes" {
  name = "yellow-taxi-eks-node-group-nodes"

  assume_role_policy = data.aws_iam_policy_document.ec2-yellow-taxi-role.json
}

resource "aws_iam_role_policy_attachment" "yellow-taxi-nodes-AwsEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.yellow-taxi-nodes.name
}

resource "aws_iam_role_policy_attachment" "yellow-taxi-nodes-AwsEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.yellow-taxi-nodes.name
}

resource "aws_iam_role_policy_attachment" "yellow-taxi-nodes-AwsEC2CrReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.yellow-taxi-nodes.name
}

resource "aws_eks_node_group" "yellow-taxi-private-nodes" {
  cluster_name    = aws_eks_cluster.yellow-taxi.name
  node_group_name = "yellow-taxi-private-nodes"
  #  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  node_role_arn   = aws_iam_role.yellow-taxi-nodes.arn
  subnet_ids      = [
    aws_subnet.private-us-east-1a.id,
    aws_subnet.private-us-east-1b.id,
  ]

  capacity_type = "ON_DEMAND"

  scaling_config {
    desired_size = 1
    max_size     = 5
    min_size     = 0
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }
}
