# ##############################################################################
# VPC Module — Security Groups
# ##############################################################################
#---EKS Cluster Security Group----------------------------------------------------------------------
# Allows EKS control plane to communicate with worker nodes
resource "aws_security_group" "eks_cluster" {
  name        = "${var.cluster_name}-cluster-sg"
  description = "Security group for EKS cluster control plane"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-cluster-sg"
  })
}

#--EKS Node Security Group----------------------------------------------------------------------
# Allows worker nodes to communicate with control plane and each other
resource "aws_security_group" "eks_nodes" {
  name        = "${var.cluster_name}-nodes-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-nodes-sg"
  })
}

#--Inbound Rules - Nodes -----------------------------------------------------------------------
# Allows noes to talk to each other
resource "aws_security_group_rule" "nodes_internal" {
  description              = "Allow nodes to communicate with each other"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_nodes.id
}

# Allows control plane to talk to nodes
resource "aws_security_group_rule" "cluster_to_nodes" {
  description              = "Allow EKS control plane to communicate with nodes"
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_cluster.id
}

# Allows control plane to talk to nodes on 443 (webhooks)
resource "aws_security_group_rule" "cluster_to_nodes_443" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_cluster.id
}

#Inbound Rules - Cluster -----------------------------------------------------------------------
# Allows nodes to talk to control plane
resource "aws_security_group_rule" "nodes_to_cluster" {
  description              = "Allow nodes to communicate with control plane"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_nodes.id
}

#-- Outbound Rules - Cluster ---------------------------------------------------------------------- 
# Allow all outbound from nodes (pulling images, AWS API calls)
resource "aws_security_group_rule" "nodes_outbound" {
  description       = "Allow all outbound traffic from nodes"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.eks_nodes.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# A# Allow all outbound from cluster control plane
resource "aws_security_group_rule" "cluster_outbound" {
  description       = "Allow all outbound traffic from cluster "
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.eks_cluster.id
  cidr_blocks       = ["0.0.0.0/0"]
}