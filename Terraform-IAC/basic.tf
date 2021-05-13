provider "aws" {
  region  = "${var.region}"
  profile = "${var.prof}"
}
resource "aws_vpc" "vpc1" {
  cidr_block       = "${var.range}"
  instance_tenancy = "default"

  tags = {
    Name ="${var.vpctag}"
  }
}
resource "aws_subnet" "public" {
  vpc_id     = "${aws_vpc.vpc1.id}"
  cidr_block = "${var.subrange}"
  availability_zone = "${var.zones}"
  map_public_ip_on_launch = true
  depends_on = ["aws_vpc.vpc1"]

  tags = {
    Name = "${var.subnettag}"
  }
}
resource "aws_internet_gateway" "ig" {
  vpc_id = "${aws_vpc.vpc1.id}"
  depends_on = ["aws_vpc.vpc1"]
  tags = {
    Name = "${var.igtag}"
  }

}
resource "aws_route_table" "rtable" {
  vpc_id = "${aws_vpc.vpc1.id}"
  depends_on = ["aws_internet_gateway.ig"]

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.ig.id}"

  }

  tags = {
    Name = "${var.rtag}"
  }
}
resource "aws_route_table_association" "routejoin" {
  subnet_id      = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.rtable.id}"
}

resource "aws_security_group" "cluster_sg" {
  name        = "cluster_group"
  description = "Allow all"
  vpc_id      = "${aws_vpc.vpc1.id}"

  ingress {
    description = "allow_all_ip"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
}

  tags = {
    Name = "{var.sgname}"
  }
}

resource "aws_instance" "hdfs_master" {
  ami = "${var.amiid}"
  instance_type = "${var.ec2type}"
  key_name = "${var.keyname}"
  vpc_security_group_ids = [ "${aws_security_group.cluster_sg.id}" ]
  subnet_id = "${aws_subnet.public.id}" 
tags ={
    Name = "${var.hdfs_master}"
  }
  
}

resource "aws_instance" "hdfs_slave" {
  ami = "${var.amiid}"
  instance_type = "${var.ec2type}"
  key_name = "${var.keyname}"
  vpc_security_group_ids = [ "${aws_security_group.cluster_sg.id}" ]
  subnet_id = "${aws_subnet.public.id}"
  count = "${var.hdfs_slavecount}" 
tags ={
    Name = "${var.hdfs_slave}-${count.index}"
  }
}

resource "aws_instance" "mapred_master" {
  ami = "${var.amiid}"
  instance_type = "${var.ec2type}"
  key_name = "${var.keyname}"
  vpc_security_group_ids = [ "${aws_security_group.cluster_sg.id}" ]
  subnet_id = "${aws_subnet.public.id}"
tags ={
    Name = "${var.mapred_master}"
  }
}

resource "aws_instance" "mapred_slave" {
  ami = "${var.amiid}"
  instance_type = "${var.ec2type}"
  key_name = "${var.keyname}"
  vpc_security_group_ids = [ "${aws_security_group.cluster_sg.id}" ]
  subnet_id = "${aws_subnet.public.id}"
  count = "${var.mr_slavecount}" 
tags ={
    Name = "${var.mapred_slave}-${count.index}"
  }
}

resource "aws_instance" "client" {
  ami = "${var.amiid}"
  instance_type = "${var.ec2type}"
  key_name = "${var.keyname}"
  vpc_security_group_ids = [ "${aws_security_group.cluster_sg.id}" ]
  subnet_id = "${aws_subnet.public.id}" 
tags ={
    Name = "${var.client}"
  }
  
}

resource "local_file" "Hadoop_Cluster_Ansible_Playbook" {
    content     = "[namenode]\n${ aws_instance.hdfs_master.public_ip }\tansible_ssh_user=ec2-user\n\n[datanode]\n${ aws_instance.hdfs_slave[0].public_ip }\tansible_ssh_user=ec2-user\n${ aws_instance.hdfs_slave[1].public_ip }\tansible_ssh_user=ec2-user\n\n[jobtracker]\n${ aws_instance.mapred_master.public_ip }\tansible_ssh_user=ec2-user\n\n[tasktracker]\n${ aws_instance.mapred_slave[0].public_ip }\tansible_ssh_user=ec2-user\n${ aws_instance.mapred_slave[1].public_ip }\tansible_ssh_user=ec2-user\n\n[client]\n${ aws_instance.client.public_ip }\tansible_ssh_user=ec2-user"
    filename = "/etc/ansible/hosts.txt"

  
  provisioner "local-exec" {
    command = "ansible-playbook /root/hadoop.yml"

}

}
