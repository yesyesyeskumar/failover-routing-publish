
output "iam_role_arn" {
    value = "${aws_iam_role.custlambdarole.arn}"
}

output "instance_profile_name" {
    value = "${aws_iam_instance_profile.custasgprofile.name}"
}