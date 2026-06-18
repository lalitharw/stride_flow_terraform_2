resource "aws_db_subnet_group" "stride_flow_mysql_db_subnet_group" {
  name       = "stride-flow-db-group"
  subnet_ids = var.db_subnets

  tags = {
    Name = "stride_flow_mysql_db_subnet_group"
  }
}


resource "aws_db_instance" "stride_flow_db_instance" {
  allocated_storage      = 10
  publicly_accessible    = false
  storage_encrypted      = true
  vpc_security_group_ids = [var.rds_sg_id]
  multi_az               = false
  db_name                = "stride_flow"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  username               = "rootadmin"
  password               = "admin1234"
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.stride_flow_mysql_db_subnet_group.name
}
