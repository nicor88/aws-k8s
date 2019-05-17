resource "aws_vpc" "this" {
  cidr_block = "${var.vpc_cidr_block}"

  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags = "${
    map(
     "Project", "${var.project}",
     "Stage", "${var.stage}",
     "Name", "${var.project}-${var.stage}-k8s-vpc",
     "kubernetes.io/cluster/${var.eks_cluster_name}", "shared"
    )
  }"
}

resource "aws_internet_gateway" "this" {
  vpc_id = "${aws_vpc.this.id}"

  tags = "${
    map(
     "Project", "${var.project}",
     "Stage", "${var.stage}",
     "Name", "${var.project}-${var.stage}-k8s-igw"
    )
  }"
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.this.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.this.id}"
  }

  tags = "${
    map(
     "Project", "${var.project}",
     "Stage", "${var.stage}",
     "Name", "${var.project}-${var.stage}-k8s-public-route",
     "kubernetes.io/cluster/${var.eks_cluster_name}", "shared"
    )
  }"
}

resource "aws_subnet" "public" {
  vpc_id            = "${aws_vpc.this.id}"
  cidr_block        = "${element(split(",", var.public_subnets), count.index)}"
  availability_zone = "${element(split(",", var.availability_zones), count.index)}"
  count             = "${length(split(",", var.public_subnets))}"

  tags = "${
    map(
     "Project", "${var.project}",
     "Stage", "${var.stage}",
     "Name", "${var.project}-${var.stage}-k8s-public-${element(split(",", var.availability_zones), count.index)}",
     "kubernetes.io/cluster/${var.eks_cluster_name}", "shared"
    )
  }"

  map_public_ip_on_launch = true
}

resource "aws_route_table_association" "public" {
  count          = "${length(split(",", var.public_subnets))}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_eip" "this" {
  vpc = true

  tags = {
    Name = "${var.project}-${var.stage}-k8s-elastic-ip"
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = "${aws_eip.this.id}"
  subnet_id     = "${aws_subnet.public.0.id}"

  tags = {
    Name = "${var.project}-${var.stage}-k8s-nat-gtw"
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.this.id}"

  tags {
    Name = "${var.project}-${var.stage}-k8s-private-route"
  }
}

resource "aws_route" "private_route" {
  route_table_id         = "${aws_route_table.private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.this.id}"

  depends_on = ["aws_route_table.private"]
}

resource "aws_subnet" "private" {
  vpc_id            = "${aws_vpc.this.id}"
  cidr_block        = "${element(split(",", var.private_subnets), count.index)}"
  availability_zone = "${element(split(",", var.availability_zones), count.index)}"
  count             = "${length(split(",", var.private_subnets))}"

  tags = "${
    map(
     "Project", "${var.project}",
     "Stage", "${var.stage}",
     "Name", "${var.project}-${var.stage}-k8s-private-${element(split(",", var.availability_zones), count.index)}",
     "kubernetes.io/cluster/${var.eks_cluster_name}", "shared"
    )
  }"
}

resource "aws_route_table_association" "private" {
  count          = "${length(split(",", var.private_subnets))}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}
