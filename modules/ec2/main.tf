#### VPC ####
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

data "aws_subnet_ids" "default" {
  vpc_id = aws_default_vpc.default.id
}

#### ROLE ####

resource "aws_iam_role" "es_role" {
  name = "es_role"
  path = "/"

  assume_role_policy = file("${path.root}/files/trustpolicyforec2.json")
}


resource "aws_iam_role_policy_attachment" "es-attach" {
  role      = aws_iam_role.es_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}


resource "aws_iam_instance_profile" "es_profile" {
  name = "es_profile"
  role = aws_iam_role.es_role.name
}

#### SECURITY GROUP ####

resource "aws_security_group" "es_security_group"{
  name        = "es_security_group"
  vpc_id      = aws_default_vpc.default.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH"
  }
    # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#### EC2 ####

data "aws_ssm_parameter" "amazonlinux2" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}



resource "aws_key_pair" "es_key" {
  key_name   = "es_key"
  public_key = file("${path.root}/keys/es_keypair.pub")
}

resource "aws_instance" "metricbeat" {
  ami                         = data.aws_ssm_parameter.amazonlinux2.value
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.es_profile.name
  instance_type               = "t3.medium"
  subnet_id =  tolist(data.aws_subnet_ids.default.ids)[0]

  key_name                    = aws_key_pair.es_key.key_name
  vpc_security_group_ids = [aws_security_group.es_security_group.id]
  tags = {
    Name        = "elk-log"
  }
  user_data = file("${path.root}/files/metricbeat.sh")
  
  timeouts { create = "30m" }

  provisioner "file" {
    content      = templatefile("${path.root}/templates/metricbeat.tpl", { id = var.cloud_id, auth = var.cloud_auth})
    destination = "/tmp/metricbeat.yml"
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${path.root}/keys/es_keypair")
      host        = self.public_ip
    }
  }
  provisioner "file" {
    content      = templatefile("${path.root}/templates/filebeat.tpl", { queue_id = var.sqs_id, iam_role = aws_iam_role.es_role.arn, id = var.cloud_id, auth = var.cloud_auth})
    destination = "/tmp/filebeat.yml"
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${path.root}/keys/es_keypair")
      host        = self.public_ip
    }
  }
  provisioner "file" {
    content      = templatefile("${path.root}/templates/aws.tpl", { queue_id = var.sqs_id, iam_role = aws_iam_role.es_role.arn})
    destination = "/tmp/aws.yml"
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${path.root}/keys/es_keypair")
      host        = self.public_ip
    }
  }
}

resource "null_resource" "wait_for_cloudinit" {
  provisioner "remote-exec" {
      inline = ["sudo cloud-init status --wait"]
      
      connection {
        type        = "ssh"
        user        = "ec2-user"
        private_key = file("${path.root}/keys/es_keypair")
        host        = aws_instance.metricbeat.public_ip
      }
    }
  depends_on = [ aws_instance.metricbeat ]
}



