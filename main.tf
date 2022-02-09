#vpc

resource "aws_vpc" "vpc" {
cidr_block = "${var.vpc_cidr}"
enable_dns_hostnames = true
tags = {
    Name = "vpc"
    }
}

#Public subnet

resource "aws_subnet" "vpc_public_subnet" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "${var.subnet_one_cidr}"
 #   availability_zone = "${data.aws_availability_zones.availability_zones.names[0]}"
    map_public_ip_on_launch = true
    tags = {
        Name = "vpc_public_subnet"
    }
}

#Private subnet 1

resource "aws_subnet" "vpc_private_subnet_one" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "${var.subnet_two_cidr[0]}"
 #   availability_zone = "${data.aws_availability_zones.availability_zones.names[0]}"
    map_public_ip_on_launch = true
    tags = {
        Name = "vpc_private_subnet_one"
    }
}

#Private subnet 2

resource "aws_subnet" "vpc_private_subnet_two" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "${var.subnet_two_cidr[1]}"
 #   availability_zone = "${data.aws_availability_zones.availability_zones.names[0]}"
    map_public_ip_on_launch = true
    tags = {
        Name = "vpc_private_subnet_two"
    }
}



#Internet gateway

resource "aws_internet_gateway" "vpc_ig" {
vpc_id = "${aws_vpc.vpc.id}"
tags= {
Name = "vpc_ig"
}
}

## create public route table (assosiated with internet gateway)

resource "aws_route_table" "vpc_public_subnet_route_table" {
vpc_id = "${aws_vpc.vpc.id}"
route {
cidr_block = "${var.route_table_cidr}"
gateway_id = "${aws_internet_gateway.vpc_ig.id}"
}
tags = {
Name = "vpc_public_subnet_route_table"
}
}

## create private subnet route table

resource "aws_route_table" "vpc_private_subnet_route_table" {
vpc_id = "${aws_vpc.vpc.id}"
tags = {
Name = "vpc_private_subnet_route_table"
}
}

## create default route table

resource "aws_default_route_table" "vpc_main_route_table" {
default_route_table_id = "${aws_vpc.vpc.default_route_table_id}"
tags = {
Name = "vpc_main_route_table"
}
}

## associate public subnet with public route table

resource "aws_route_table_association" "vpc_public_subnet_route_table" {
subnet_id = "${aws_subnet.vpc_public_subnet.id}"
route_table_id = "${aws_route_table.vpc_public_subnet_route_table.id}"
}

## associate private subnets with private route table

resource "aws_route_table_association" "vpc_private_subnet_one_route_ta" {
subnet_id = "${aws_subnet.vpc_private_subnet_one.id}"
route_table_id = "${aws_route_table.vpc_private_subnet_route_table.id}"
}
resource "aws_route_table_association" "vpc_private_subnet_two_route_ta" {
subnet_id = "${aws_subnet.vpc_private_subnet_two.id}"
route_table_id = "${aws_route_table.vpc_private_subnet_route_table.id}"
}

##create security group for web

resource "aws_security_group" "web_security_group" {
name = "web_security_group"
description = "Allow all inbound traffic"
vpc_id = "${aws_vpc.vpc.id}"
tags = {
Name = "vpc_web_security_group"
}
}

## create security group ingress rule for web
resource "aws_security_group_rule" "web_ingress" {
count = "${length(var.web_ports)}"
type = "ingress"
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
from_port = "${element(var.web_ports, count.index)}"
to_port = "${element(var.web_ports, count.index)}"
security_group_id = "${aws_security_group.web_security_group.id}"
}
## create security group egress rule for web
resource "aws_security_group_rule" "web_egress" {
count = "${length(var.web_ports)}"
type = "egress"
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
from_port = "${element(var.web_ports, count.index)}"
to_port = "${element(var.web_ports, count.index)}"
security_group_id = "${aws_security_group.web_security_group.id}"
}