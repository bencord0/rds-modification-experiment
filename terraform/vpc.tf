variable "az_count" {
  default = 2
}

resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  assign_generated_ipv6_cidr_block = true
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

resource "aws_egress_only_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

data "aws_availability_zones" "azs" {}

resource "aws_subnet" "default" {
  vpc_id     = "${aws_vpc.default.id}"

  count           = "${var.az_count}"
  cidr_block      = "${cidrsubnet(aws_vpc.default.cidr_block, 4, count.index)}"
  ipv6_cidr_block = "${cidrsubnet(aws_vpc.default.ipv6_cidr_block, 8, count.index)}"

  availability_zone = "${element(data.aws_availability_zones.azs.names, count.index)}"

  map_public_ip_on_launch         = true
  assign_ipv6_address_on_creation = true
}

resource "aws_eip" "nat" {
  count = "${var.az_count}"
  vpc   = true
}

resource "aws_nat_gateway" "default" {
  count = "${var.az_count}"
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.default.*.id, count.index)}"
}

resource "aws_route_table" "default" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = "${aws_internet_gateway.default.id}"
  }
}

resource "aws_route_table_association" "default" {
  count = "${var.az_count}"

  route_table_id = "${aws_route_table.default.id}"
  subnet_id      = "${element(aws_subnet.default.*.id, count.index)}"
}
