//provedor AWS e região escolhida
provider "aws" {
  region = "us-east-1"
}

//criando a nuvem privada virtual
resource "aws_vpc" "vpc_italo" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

//recurso para criar um VPC Internet Gateway.
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc_italo.id
}

//criando sub redes publicas e privadas
resource "aws_subnet" "public_subnet_a" {
  vpc_id     = aws_vpc.vpc_italo.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id     = aws_vpc.vpc_italo.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id     = aws_vpc.vpc_italo.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1c"
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id     = aws_vpc.vpc_italo.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1d"
}

//criando o banco de dados com acesso restrito
//Disponibilidade em múltiplos AZ
//réplica que pode ser usada para consultas
//Backup automático
//Monitoramento pelo CloudWatch
//Peformace de desenpenho habilitadas
resource "aws_db_instance" "banco" {
  allocated_storage = 10
  engine = "postgres"
  engine_version = "12.5"
  instance_class = "db.t2.micro"
  publicly_accessible = false
  name = "banco"
  username = "admini"
  password = "02040608"
  backup_retention_period = 14
  backup_window = "11:00-11:45"
  multi_az = true
  performance_insights_enabled = true
  enabled_cloudwatch_logs_exports = ["postgresql"]
  skip_final_snapshot = true
  db_subnet_group_name = aws_db_subnet_group.db_subnet.id
}

resource "aws_cloudwatch_log_group" "dbcldwatch_log" {
  name              = "mydb_cloudwatch_log"
  retention_in_days = 90
}

resource "aws_db_instance" "postgresql-read-replica" {
  name = "banco1" 
  instance_class = "db.t2.micro"
  replicate_source_db = aws_db_instance.banco.id
  skip_final_snapshot = true
  final_snapshot_identifier = null
}

//Agrupa a sub redes do banco de dados
resource "aws_db_subnet_group" "db_subnet" {
  name = "dbsubnet"
  subnet_ids = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id, aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
}
