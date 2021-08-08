  
output "subnets" {
  value = aws_subnet.public[*]
}

output "dns-name" {
  value = aws_lb.web.dns_name
  
}