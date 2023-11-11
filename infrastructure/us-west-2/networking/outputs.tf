

output "private_sg_id" {
    value = aws_security_group.app_instance_sg.id
}


output "lb_sg_id" {
    value = aws_security_group.app_lb_sg.id
}


output "private_subnet_ids" {
    value = aws_subnet.app_private.*.id
}

output "public_subnet_ids" {
    value = aws_subnet.app_public.*.id
}

output "vpc_id" {
    value = aws_vpc.appvpc.id
}

