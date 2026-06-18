output "instance" {
  value = aws_instance.example.*.id
}
