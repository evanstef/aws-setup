# Cari AMI Ubuntu 24.04 terbaru otomatis (biar gak hardcode ID yang bisa basi)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # ID resmi Canonical (pembuat Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

# Firewall: atur port mana yang boleh diakses
resource "aws_security_group" "web" {
  name        = "devops-learn-${var.environment}-web-sg" # 👈 prefix env biar unik
  description = "Allow SSH, HTTP, HTTPS"
  vpc_id      = var.vpc_id # 👈 taro SG di VPC kita (bukan default VPC)

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # semua IP (buat belajar; idealnya IP kamu doang)
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # semua protokol
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# security group for database
resource "aws_security_group" "db" {
  name        = "devops-learn-${var.environment}-db-sg" # 👈 prefix env
  description = "Allow PostgreSQL traffic"
  vpc_id      = var.vpc_id # 👈 SG db juga di VPC kita (harus se-VPC sama SG web)

  ingress {
    description     = "PostgreSQL"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id] # cuma server yang nempel SG "web" (EC2) yang boleh masuk
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Daftarin public key kita ke AWS (pakai ulang kunci dari Step 4)
resource "aws_key_pair" "deploy" {
  key_name   = "deploy-key-${var.environment}" # 👈 prefix env (key_name harus unik)
  public_key = file(pathexpand("~/.ssh/id_ed25519_deploy.pub"))
}

# Elastic IP untuk server
resource "aws_eip" "app_evan" {
  instance = aws_instance.app.id
  domain   = "vpc"
}

# route53 dns setting — domain di-pass per-env biar gak nabrak
resource "aws_route53_record" "app" {
  zone_id = "Z05156121HY0DKY5WZJHC"
  name    = var.app_domain # 👈 dari input (prod: app..., staging: app-staging...)
  type    = "A"
  ttl     = 300
  records = [aws_eip.app_evan.public_ip]
}

# khusus grafana
resource "aws_route53_record" "grafana" {
  zone_id = "Z05156121HY0DKY5WZJHC"
  name    = var.grafana_domain # 👈 dari input
  type    = "A"
  ttl     = 300
  records = [aws_eip.app_evan.public_ip]
}

# Server-nya sendiri
resource "aws_instance" "app" {
  ami                    = data.aws_ami.ubuntu.id       # AMI Ubuntu dari data source
  instance_type          = var.instance_type            # dari input module
  key_name               = aws_key_pair.deploy.key_name # kunci SSH
  vpc_security_group_ids = [aws_security_group.web.id]  # firewall
  subnet_id              = var.public_subnet_id         # 👈 EC2 ditaro di PUBLIC subnet

  # nambah disk server
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  metadata_options {
    http_tokens = "required"
  }

  # Script yang jalan OTOMATIS pas server pertama boot (install Docker)
  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    curl -fsSL https://get.docker.com | sh
    usermod -aG docker ubuntu

    # Swap 2GB — codify biar gak keulang kejadian RAM mentok
    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
  EOF

  # Kalau user_data berubah → server dibikin ulang (biar script-nya jalan lagi)
  user_data_replace_on_change = true

  tags = {
    Name = "devops-learn-${var.environment}-app" # 👈 prefix env
  }

  lifecycle {
    ignore_changes = [ami]
  }
}

# Database-nya sendiri (RDS = Postgres managed, lifecycle terpisah dari EC2)
resource "aws_db_instance" "db" {
  identifier             = "devops-learn-${var.environment}-db" # 👈 prefix env (identifier harus unik)
  engine                 = "postgres"                           # jenis DB
  storage_encrypted      = true                                 # 🔒 enkripsi disk database (fix Trivy AWS-0080)
  engine_version         = "16"                                 # samain sama Postgres lama
  instance_class         = "db.t3.micro"                        # ukuran (RDS pakai instance_class, BUKAN instance_type)
  allocated_storage      = 20                                   # disk 20 GB
  db_name                = "devopslearn"                        # nama database awal
  username               = "devops"                             # user master
  password               = var.db_password                      # nilai dari input module
  vpc_security_group_ids = [aws_security_group.db.id]           # firewall: cuma EC2 yang boleh akses
  db_subnet_group_name   = var.db_subnet_group_name             # 👈 RDS ditaro di PRIVATE subnet (via subnet group)
  publicly_accessible    = false                                # DB gak kebuka ke internet
  skip_final_snapshot    = true                                 # pas destroy, gak maksa bikin snapshot dulu (buat belajar)
}
