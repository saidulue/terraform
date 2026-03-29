# ============================================
# VPC Configuration
# ============================================
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-${var.vpc_name}"
    Environment = var.environment
  }
}

# ============================================
# Subnet Configuration
# ============================================
resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment}-subnet"
    Environment = var.environment
  }

  depends_on = [aws_vpc.main]
}

# ============================================
# Internet Gateway Configuration
# ============================================
resource "aws_internet_gateway" "main" {
  tags = {
    Name        = "${var.environment}-igw"
    Environment = var.environment
  }
}

# Explicit IGW Attachment (better for deletion order)
resource "aws_internet_gateway_attachment" "main" {
  internet_gateway_id = aws_internet_gateway.main.id
  vpc_id              = aws_vpc.main.id

  depends_on = [aws_internet_gateway.main, aws_vpc.main]
}

# ============================================
# Route Table Configuration
# ============================================
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${var.environment}-route-table"
    Environment = var.environment
  }

  depends_on = [aws_internet_gateway_attachment.main]
}

# Route Table Association
resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id

  depends_on = [aws_route_table.main, aws_subnet.main]
}

# ============================================
# Security Group Configuration
# ============================================
resource "aws_security_group" "main" {
  name        = "${var.environment}-sg"
  description = "Security group for ${var.environment} environment"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All traffic"
  }

  tags = {
    Name        = "${var.environment}-sg"
    Environment = var.environment
  }

  depends_on = [aws_vpc.main]
}

# ============================================
# EC2 Instance Configuration
# ============================================
resource "aws_instance" "main" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.main.id]

  tags = {
    Name        = "${var.environment}-${var.instance_name}"
    Environment = var.environment
  }

  depends_on = [aws_subnet.main, aws_security_group.main, aws_internet_gateway_attachment.main]
}
