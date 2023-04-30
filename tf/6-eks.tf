data "aws_iam_policy_document" "eks-yellow-taxi-role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "yellow-taxi" {
  name               = "eks-cluster-yellow-taxi"
  assume_role_policy = data.aws_iam_policy_document.eks-yellow-taxi-role.json
}

resource "aws_iam_role_policy_attachment" "yellow-taxi-AwsEksClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.yellow-taxi.name
}

variable "cluster_name" {
  default = "yellow-taxi"
  type = string
  description = "AWS EKS CLuster Name"
  nullable = false
}

resource "aws_eks_cluster" "yellow-taxi" {
  name     = var.cluster_name
  role_arn = aws_iam_role.yellow-taxi.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.private-us-east-1a.id,
      aws_subnet.private-us-east-1b.id,
      aws_subnet.public-us-east-1a.id,
      aws_subnet.public-us-east-1b.id
    ]
  }

  depends_on = [aws_iam_role_policy_attachment.yellow-taxi-AwsEksClusterPolicy]
}
