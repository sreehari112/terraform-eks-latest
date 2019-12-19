resource "aws_security_group" "kubernetes-server-instance-sg" {
  name        = "terraform-kubernetes-client-sg"
  description = "kubectl_instance_sg"
  vpc_id      = aws_vpc.demo.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform_kubectl_server-SG"
  }
}

resource "aws_key_pair" "example" {
  key_name = "eks"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "kubernetes-server" {
  instance_type          = var.instance_type
  ami                    = var.instance_ami
  key_name               = aws_key_pair.example.key_name
  subnet_id              = aws_subnet.demo.0.id
  vpc_security_group_ids = [aws_security_group.kubernetes-server-instance-sg.id]

# user_data = file("kubectl.sh")
provisioner "file" {
  source      = "/root/eks-getting-started/ekscluster-aws/kubectl.sh"
  destination = "~/kubectl.sh"
   connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("~/.ssh/id_rsa")
    host     = self.public_ip
  }
}
  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("~/.ssh/id_rsa")
    host     = self.public_ip
  }


 provisioner "remote-exec" {
    inline = [
"sudo yum update -y",
"sudo yum install python3 -y",
"sudo yum install unzip -y",
"sudo pip3 install awscli",
"sudo yum install git -y",
"mkdir ~/.aws/",
"echo -e '[sriahri]\nregion = us-east-1\noutput = json' >> ~/.aws/config",
"echo -e '[sriahri]\n aws_access_key_id = ************\naws_secret_access_key = *********************' >> ~/.aws/credentials",
"aws configure set aws_access_key_id ****************",
"aws configure set aws_secret_access_key *********************",
"aws configure set default.region us-east-1",
"curl -o kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/linux/amd64/kubectl",
"chmod +x ./kubectl",
"mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH",
"echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc",
"curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/linux/amd64/aws-iam-authenticator",
"chmod +x ./aws-iam-authenticator",
"mkdir -p $HOME/bin && cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$HOME/bin:$PATH",
"echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc",
"aws eks --region us-east-1 update-kubeconfig --name terraform-eks-automation-cluster",
"git clone https://github.com/<url of the deployment files stored>",
"cd ~/kubernetes-examples/",
"kubectl apply -f deployment.yml",
    ]
  }

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "50"
    delete_on_termination = "true"
  }

  tags = {
    Name = "var.server_name"
  }
}

resource "aws_eip" "ip" {
  instance = aws_instance.kubernetes-server.id
  vpc      = true

  tags = {
    Name = "server_eip"
  }
}
