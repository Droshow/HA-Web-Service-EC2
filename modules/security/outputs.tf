output "EC2_sg" {
    description = "for the use of SG"
    value = aws_security_group.EC2_sg.id
}

output "alb_sg" {
    description = "for the use of SG"
    value = aws_security_group.alb_sg.id
}