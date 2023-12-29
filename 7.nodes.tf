resource "aws_iam_role" "nodes" {
  name = "eks_node"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKSWorkerNodePolicy" {
  
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role = aws_iam_role.nodes.name 
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKS-CNI-Policy" {
  
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEC2ContainerRegistryReadOnly" {
  
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role = aws_iam_role.nodes.name 
}

resource "aws_eks_node_group" "private_node" {
  cluster_name = aws_eks_cluster.demo.name 
  node_group_name = "private-node"
  node_role_arn = aws_iam_role.nodes.arn 

  subnet_ids = [
    aws_subnet.private-us-east-1a.id,
    aws_subnet.private-us-east-1b.id
  ]
capacity_type = "ON_DEMAND"
instance_types = ["t3.micro"]
scaling_config {
  desired_size = 2
  max_size = 5
  min_size = 2
}
update_config {
  max_unavailable = 1
}
labels = {
  role = "general"
}
launch_template {
  name = aws_launch_template.eks-with-disk.name 
  version = aws_launch_template.eks-with-disk.latest_version
}
depends_on = [ aws_iam_policy_attachment.demo-AmazonEKSClusterPolicy,
aws_iam_role_policy_attachment.node-AmazonEKSWorkerNodePolicy,
aws_iam_role_policy_attachment.node-AmazonEC2ContainerRegistryReadOnly, ]
}

resource "aws_launch_template" "eks-with-disk" {
  name = "eks-with-disk"
  block_device_mappings {
    device_name = "/dev/xvdb"
    ebs {
    volume_size = 20
    volume_type = "gp2"
  }
  }
   
}