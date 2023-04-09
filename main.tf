
##################################################################################
# VARIABLES
##################################################################################


variable "aws_access_key" {}
variable "aws_secret_key"{}
variable "private_key_path" {}
variable "key_name" {}
variable "region" {
  
  default =  "us-east-1"
  type = string
}
##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    region = var.region  
  
}

##################################################################################
# DATA
##################################################################################

data "aws_ami" "aws-linux" {
    #in true yani  akharin version
    most_recent = true
    owners = [ "amazon" ]

    #ina marbot be entekhab hhd hast
     filter {
    name   = "name"
    values = ["amzn-ami-hvm*"]
    } 
    filter {
      name = "root-device-type"
      values = "ebs"
    }
    filter {
      name = "virtualzation-type"
      values = [ "hvm" ]

    }
}


##################################################################################
# RESOURCES
##################################################################################


resource "aws_default_vpc" "default" {

  
}

resource "aws_security_group" "allow_traffic" {
    name = "ngin_demo"
    description = "allow port for ngin demo"
    vpc_id = aws_default_vpc.default.id
    ingress {
        #mesle map kardane porte bironi be dakhel
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]

    }

        ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]

    }

        egress {
        from_port = 0
        to_port = 0
        #-1 yani all protocols
        protocol = -1
        cidr_blocks = [ "0.0.0.0/0" ]

    }

}

resource "aws_instance" "nginx" {
  ami                    = data.aws_ami.aws-linux.id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  #az inja be bad vasl mishim be mashin va code mizanim
  #ssh to vm and install app
  connection {
    type        = "ssh"
    # connect to ip assign from aws
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.private_key_path)

  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install nginx -y",
      "sudo service nginx start"
    ]
  }
}

##################################################################################
# OUTPUT
##################################################################################

output "aws_instance_public_dns" {
  value = aws_instance.nginx.public_dns
}