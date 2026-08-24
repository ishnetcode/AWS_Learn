# =========================================================================
# SIMPLE VERSION — one file, local state, no modules, no toggles.
# Goal: see terraform init / plan / apply / destroy work end to end, and
# understand every line. We'll layer back in "real" practices one at a time
# after this clicks.
# =========================================================================

terraform {
  required_version = ">= 1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # No backend block at all — Terraform defaults to saving state as a plain
  # file called terraform.tfstate right here in this folder. That's it.
  # That's "local state." Fine for solo learning; the S3/DynamoDB version
  # solves a team-sharing problem you don't have yet.
}

provider "aws" {
  region  = "eu-west-2"
  profile = "devwork"
}

# ---------- The network itself ----------

resource "aws_vpc" "learning" {
  cidr_block           = "10.20.0.0/16" # ~65,000 IP addresses, far more than we need
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "learning-vpc"
  }
}

# Lets anything in a PUBLIC subnet reach the internet directly
resource "aws_internet_gateway" "learning" {
  vpc_id = aws_vpc.learning.id

  tags = {
    Name = "learning-igw"
  }
}

# ---------- One public subnet (no loops, no count, just one) ----------

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.learning.id
  cidr_block              = "10.20.1.0/24" # 256 IPs, plenty for now
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = true # instances launched here get a public IP automatically

  tags = {
    Name = "learning-public-subnet"
  }
}

# A route table = "the rules for where traffic is allowed to go"
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.learning.id

  route {
    cidr_block = "0.0.0.0/0" # "anywhere on the internet"
    gateway_id = aws_internet_gateway.learning.id
  }

  tags = {
    Name = "learning-public-rt"
  }
}

# Attaches the route table to the subnet — without this, the subnet exists
# but has no idea it's allowed to reach the internet.
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ---------- One private subnet (no internet route at all) ----------

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.learning.id
  cidr_block        = "10.20.2.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "learning-private-subnet"
  }
}
# Deliberately: no route table, no NAT gateway, no internet gateway attached.
# Anything launched here can talk to other things inside the VPC, but has
# zero path in or out to the public internet. That's the whole point of a
# private subnet. (We'll add a NAT gateway back in as its own lesson later —
# it's the single most expensive piece, so it's worth understanding in
# isolation before paying for it.)

# ---------- What Terraform prints after apply ----------

output "vpc_id" {
  value = aws_vpc.learning.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}
