resource "aws_subnet" "private" {
  count = "${length(var.availability_zones)}"
  cidr_block = "${cidrsubnet(var.cidr_block, 3, count.index + length(var.availability_zones))}"
  availability_zone = "${element(var.availability_zones, count.index)}"
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Name = "${format("%s-%s-private-subnet", var.vpc_name, element(var.availability_zones, count.index))}"
  }
  depends_on = ["aws_subnet.public"]
}

resource "aws_eip" "eip" {
  count = "${length(var.availability_zones)}"
  vpc = true
  tags {
    Name = "${format("%s-%s-eip", var.vpc_name, element(var.availability_zones, count.index))}"
  }
}

resource "aws_nat_gateway" "nat" {
  count = "${length(var.availability_zones)}"
  allocation_id = "${element(aws_eip.eip.*.id, count.index)}"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
  lifecycle {
    create_before_destroy = true
  }
  tags {
    Name = "${format("%s-%s-natgw", var.vpc_name, element(var.availability_zones, count.index))}"
  }
}

resource "aws_route_table" "private_route_table" {
  count = "${length(var.availability_zones)}"
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Name = "${format("%s-%s-private-route-table", var.vpc_name, element(var.availability_zones, count.index))}"
  }
}

resource "aws_route" "private_route" {
  count = "${length(var.availability_zones)}"
  route_table_id = "${element(aws_route_table.private_route_table.*.id, count.index)}"
  nat_gateway_id = "${element(aws_nat_gateway.nat.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  depends_on = ["aws_route_table.public_route_table"]
}

resource "aws_route_table_association" "private_route_table_association" {
  count = "${length(var.availability_zones)}"
  route_table_id = "${element(aws_route_table.private_route_table.*.id, count.index)}"
  subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
}