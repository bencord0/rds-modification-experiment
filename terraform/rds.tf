resource "random_string" "username" {
  length  = 20
  special = false
}

resource "random_string" "password" {
  length  = 20
  special = false
}

resource "aws_security_group" "postgres" {
  name   = "postgres"
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"

    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_db_subnet_group" "default" {
  name = "main"

  subnet_ids = ["${aws_subnet.default.*.id}"]
}

resource "aws_db_parameter_group" "default" {
  name   = "postgres96"
  family = "postgres9.6"
}

resource "aws_db_instance" "master" {
  name = "myrds"

  apply_immediately   = true
  multi_az            = true
  publicly_accessible = true
  skip_final_snapshot = true

  allocated_storage = 10
  storage_type      = "gp2"
  engine            = "postgres"
  engine_version    = "9.6.8"
  instance_class    = "db.t2.micro"

  username = "${random_string.username.result}"
  password = "${random_string.password.result}"

  backup_retention_period = 1

  db_subnet_group_name   = "${aws_db_subnet_group.default.id}"
  parameter_group_name   = "${aws_db_parameter_group.default.id}"
  vpc_security_group_ids = ["${aws_security_group.postgres.id}"]

  lifecycle {
    ignore_changes = ["instance_class"]
  }
}

resource "aws_db_instance" "replica" {
  replicate_source_db = "${aws_db_instance.master.id}"

  instance_class = "db.t2.micro"

  publicly_accessible = true
  skip_final_snapshot = true

  lifecycle {
    ignore_changes = ["instance_class"]
  }
}

locals {
  username = "${random_string.username.result}"
  password = "${random_string.password.result}"
  dbname   = "${aws_db_instance.master.name}"

  master_address  = "${aws_db_instance.master.address}"
  replica_address = "${aws_db_instance.replica.address}"
}

output "master_database_url" {
  value = "postgres://${local.username}:${local.password}@${local.master_address}/${local.dbname}"
}

output "replica_database_url" {
  value = "postgres://${local.username}:${local.password}@${local.replica_address}/${local.dbname}"
}
