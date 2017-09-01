/*
	use the provider function to show what the cloud provider is going to be. 
*/
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

/*
	put in the details of the VPC that is being constructed. The variables from this are created in the variables.tf file for reference. 
*/
resource "aws_vpc" "default" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    tags {
        Name = "terraform-aws-vpc"
    }
}


/*
	Create an internet gateway so that both of the instances created in the public subnet can access the internet through the internet gateway.The route table for the VPC will
	link from 0.0.0.0/0 to the internet gateway to allow traffic in and out for the internet. 
*/
resource "aws_internet_gateway" "default" {
    vpc_id = "${aws_vpc.default.id}"
}


/*
  Public Subnet creation this is the subnet created to have an internet inbound and outbound. We add in the changes to the route table and create the subnet. 
*/
resource "aws_subnet" "eu-west-2-public" {
    vpc_id = "${aws_vpc.default.id}"

    cidr_block = "${var.public_subnet_cidr}"
    availability_zone = "eu-west-2a"

    tags {
        Name = "Public Subnet"
    }
}

resource "aws_route_table" "eu-west-2-public" {
    vpc_id = "${aws_vpc.default.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.default.id}"
    }

    tags {
        Name = "Public Subnet"
    }
}

resource "aws_route_table_association" "eu-west-2-public" {
    subnet_id = "${aws_subnet.eu-west-2-public.id}"
    route_table_id = "${aws_route_table.eu-west-2-public.id}"
}

/*
  We want to create two web servers that have the HTTP ports open so that the deployed GO application can be shown to the internet. First step is to create the correct security
  group
*/
resource "aws_security_group" "app" {
    name = "vpc_web"
    description = "Allow incoming HTTP connections."

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.default.id}"

    tags {
        Name = "AppSeverSecGroup"
    }
}

resource "aws_instance" "app-1" {
    ami = "ami-896369ed"
    availability_zone = "eu-west-2a"
    instance_type = "t2.micro"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.app.id}"]
    subnet_id = "${aws_subnet.eu-west-2-public.id}"
    associate_public_ip_address = true
    source_dest_check = false


    tags {
        Name = "App Server 1"
    }
}
/*
	currently we will put both of the app servers in the same zone and later update this to multiple zones. 
*/

resource "aws_instance" "app-2" {
    ami = "ami-896369ed"
    availability_zone = "eu-west-2a"
    instance_type = "t2.micro"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.app.id}"]
    subnet_id = "${aws_subnet.eu-west-2-public.id}"
    associate_public_ip_address = true
    source_dest_check = false


    tags {
        Name = "App Server 2"
    }
}

/*
	assign an elastic ip to the application severs. 
*/
resource "aws_eip" "app-1" {
    instance = "${aws_instance.app-1.id}"
    vpc = true
}

resource "aws_eip" "app-2" {
    instance = "${aws_instance.app-2.id}"
    vpc = true
}

# Create a new load balancer
resource "aws_elb" "app_elb" {
  name               = "application-terraform-elb"
  subnets = ["${aws_subnet.eu-west-2-public.id}"]
  security_groups = ["${aws_security_group.app.id}"]
  
  
  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  instances                   = ["${aws_instance.app-1.id}","${aws_instance.app-2.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags {
    Name = "application-terraform-elb"
  }
}