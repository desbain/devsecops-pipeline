# ##################################################################
# VPC Module -creates to network foundation for the EKS cluster
# ##################################################################
resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true  # Required for EKS nodes to register with the cluster
    enable_dns_support   = true    #Required for EKS service discovery
    tags                 = merge(var.tags, {
        Name = "${var.cluster_name}-vpc"
    })
}

# --Internet Gateway----------------------------------------------------------------
# Allows public subnets to reach the internet
resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id

    tags = merge(var.tags, {
        Name = "${var.cluster_name}-igw"
    })
}

#---Public Subnet----------------------------------------------------------------------
# Used for load balancers only - not for EKS nodes
resource "aws_subnet" "public" {
    count =2
    vpc_id = aws_vpc.main.id
     cidr_block = cidrsubnet(var.vpc_cidr, 8 , count.index) # Creates 2 /24 subnets from the VPC CIDR
     availability_zone = "${var.aws_region}${count.index == 0 ? "a" : "b"}" # Distributes subnets across AZs
     map_public_ip_on_launch = true # Required for public subnets

     tags = merge(var.tags, {
        Name = "${var.cluster_name}-public-${count.index + 1}"
        "kubernetes.io/role/elb" = "1" # Tag for AWS Load Balancers
     })
}  

#---Private Subnet----------------------------------------------------------------------
# EKS nodes live here - no direct internet access
resource "aws_subnet" "private" {
    count = 2
    vpc_id = aws_vpc.main.id
     cidr_block = cidrsubnet(var.vpc_cidr, 8 , count.index + 2) # Creates 2 /24 subnets from the VPC CIDR
     availability_zone = "${var.aws_region}${count.index == 0 ? "a" : "b"}" # Distributes subnets across AZs

     tags = merge(var.tags, {
        Name = "${var.cluster_name}-private-${count.index + 1}"
        "kubernetes.io/role/internal-elb" = "1" # Tag for EKS worker nodes
        "kubernetes.io/cluster/${var.cluster_name}" = "shared" # Tag for EKS cluster ownership
     })
}

#---Elastic IP for NAT Gateway----------------------------------------------------------------------
resource "aws_eip" "nat" {
    domain = "vpc"
    tags = merge(var.tags, {
        Name = "${var.cluster_name}-nat-eip"
    })
}

#--NAT Gateway----------------------------------------------------------------------
# Allows private nodes to pull images from internet
# but blocks all inbound traffic from the internet
resource "aws_nat_gateway" "main" {
    allocation_id = aws_eip.nat.id
    subnet_id = aws_subnet.public[0].id # Place NAT in the first public subnet

    tags = merge(var.tags, {
        Name = "${var.cluster_name}-nat-gateway"
    })
    depends_on = [ aws_internet_gateway.main] # Ensure IGW is created before NAT
}

#--Public Route Table----------------------------------------------------------------------
# Routes traffic from public subnets to the internet
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }
    tags = merge(var.tags, {
        Name = "${var.cluster_name}-public-rt"
    })
}

#--Private Route Table----------------------------------------------------------------------
# Routes traffic from private subnets to the NAT gateway
resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.main.id
    }
    tags = merge(var.tags, {
        Name = "${var.cluster_name}-private-rt"
    })
}

#--Route Table Associations----------------------------------------------------------------------
# Associates public subnets with the public route table
resource "aws_route_table_association" "public" {
    count = 2
    subnet_id = aws_subnet.public[count.index].id
    route_table_id = aws_route_table.public.id
}

# Associates private subnets with the private route table
resource "aws_route_table_association" "private" {
    count = 2
    subnet_id = aws_subnet.private[count.index].id
    route_table_id = aws_route_table.private.id
}