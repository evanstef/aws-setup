resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "devops-learn-${var.environment}-vpc"
  }
}

# setip subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "devops-learn-${var.environment}-public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-southeast-1a"
  tags = {
    Name = "devops-learn-${var.environment}-private-subnet"
  }
}

# Internet Gateway: gerbang VPC ke internet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "devops-learn-${var.environment}-igw"
  }
}

# Route table public: traffic ke internet (0.0.0.0/0) diarahkan lewat IGW
# (route "local" untuk 10.0.0.0/16 otomatis ada, gak perlu ditulis)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"                  # tujuan: internet (catch-all)
    gateway_id = aws_internet_gateway.main.id # lewat: Internet Gateway
  }

  tags = {
    Name = "devops-learn-${var.environment}-public-rt"
  }
}

# Nempelin route table public ke public subnet → INI yang bikin si "public" beneran public
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# setup nat gateway untuk private subnet + elastic ip
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "devops-learn-${var.environment}-nat-eip"
  }
}

# setup nat gatewaynya
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
  tags = {
    Name = "devops-learn-${var.environment}-nat-gateway"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
  tags = {
    Name = "devops-learn-${var.environment}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# Private subnet KE-2 di AZ berbeda (1b) — RDS WAJIB minimal 2 AZ
resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-southeast-1b"
  tags = {
    Name = "devops-learn-${var.environment}-private-subnet-2"
  }
}

# Association private_2 → private route table yang SAMA (keluar lewat NAT juga)
resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}

# DB Subnet Group — RDS butuh ini (kumpulan subnet ≥2 AZ buat naro DB)
resource "aws_db_subnet_group" "main" {
  name       = "devops-learn-${var.environment}-db-subnet-group"
  subnet_ids = [aws_subnet.private.id, aws_subnet.private_2.id]
  tags = {
    Name = "devops-learn-${var.environment}-db-subnet-group"
  }
}

