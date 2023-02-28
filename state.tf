terraform {
  backend "s3" {
    bucket         = "state-bucket-ec2-instance"
    key            = "ec2-instance"
    region         = "eu-central-1"
    profile = "SolutionArchitect"
  }
}