output "vpc_id" {
  value = "${aws_vpc.this.id}"
}

output "vpc_cidr" {
  value = "${aws_vpc.this.cidr_block}"
}

output "public_subnet_ids" {
  value = "${join(",", aws_subnet.public.*.id)}"
}

output "public_route_table_id" {
  value = "${aws_route_table.public.id}"
}

output "internet_gateway" {
  value = "${aws_internet_gateway.this.id}"
}

output "private_subnet_ids" {
  value = "${join(",", aws_subnet.private.*.id)}"
}

output "private_route_table_id" {
  value = "${aws_route_table.private.id}"
}

output "nat_gateway" {
  value = "${aws_nat_gateway.this.id}"
}
