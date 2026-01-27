output "public_subnets" {
  value = data.aws_subnets.public.ids
}

output "private_subnets" {
  value = data.aws_subnets.private.ids
}
