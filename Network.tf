#Create a VPC
resource "aws_vpc" "book-review-demo-vpc" {
  cidr_block = "10.0.0.0/20"

  tags = {
    Name = "book-review-demo-vpc"
  }
}

#Creating the public & private subnets
resource "aws_subnet" "book-review-demo-subnet-public1" { #Public Subnet
  vpc_id            = aws_vpc.book-review-demo-vpc.id
  cidr_block        = "10.0.0.0/23"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Public Subnet 1"
  }
}

resource "aws_subnet" "book-review-demo-subnet-db-1" { #Private Database Subnet 1
  vpc_id            = aws_vpc.book-review-demo-vpc.id
  cidr_block        = "10.0.8.0/23"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Private Database Subnet 1"
  }
}

resource "aws_subnet" "book-review-demo-subnet-db-2" { #Private Database Subnet 2
  vpc_id            = aws_vpc.book-review-demo-vpc.id
  cidr_block        = "10.0.10.0/23"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Private Database Subnet 2"
  }
}

#Creating the DB Subnet Group. This has to be created before the RDS instance, because it serves as a mandatory networking foundation that tells Amazon RDS exactly where it is allowed to place your database.
resource "aws_db_subnet_group" "mysql_subnet_group" {
  name       = "mysql-subnet-group"
  subnet_ids = [aws_subnet.book-review-demo-subnet-db-1.id, aws_subnet.book-review-demo-subnet-db-2.id] #Connecting it to the DB subnets. 2 are required for high availability and disaster recovery.

  tags = {
    Name = "mysql-subnet-group"
  }
}

#Creating the Internet Gateway and Route Tables
resource "aws_internet_gateway" "book-review-demo-igw" { #Internet Gateway
  vpc_id = aws_vpc.book-review-demo-vpc.id

  tags = {
    Name = "book-review-demo-igw"
  }
}

resource "aws_route_table" "book-review-demo-private-rt" { #Private Route Table
  vpc_id = aws_vpc.book-review-demo-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.book-review-demo-igw.id
  }

  tags = {
    Name = "book-review-demo-private-rt"
  }
}

resource "aws_route_table" "book-review-demo-public-rt" { #Public Route Table
  vpc_id = aws_vpc.book-review-demo-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.book-review-demo-igw.id
  }

  tags = {
    Name = "book-review-demo-public-rt"
  }
}

#Associating the subnets with the route tables
resource "aws_route_table_association" "Public_Subnet1_Association" {
  subnet_id      = aws_subnet.book-review-demo-subnet-public1.id
  route_table_id = aws_route_table.book-review-demo-public-rt.id
}

resource "aws_route_table_association" "Private_Subnet1_Association" {
  subnet_id      = aws_subnet.book-review-demo-subnet-db-1.id
  route_table_id = aws_route_table.book-review-demo-private-rt.id
}

#Creating Security Groups
resource "aws_security_group" "book_review_web_sg" { #Web Security Group
  name        = "Allow_web_traffic"
  description = "Allow outbound web traffic"
  vpc_id      = aws_vpc.book-review-demo-vpc.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Be cautious: this allows access from anywhere on the internet
  }

  egress {
    from_port   = 0
    to_port     = 65355
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allows outbound TCP traffic to anywhere
  }
}

resource "aws_security_group" "book_review_app_sg" { #App Security Group
  name        = "Allow_app_traffic"
  description = "Allow inbound app traffic"
  vpc_id      = aws_vpc.book-review-demo-vpc.id

  ingress {
    from_port       = 3001
    to_port         = 3001
    protocol        = "tcp"
    security_groups = [aws_security_group.book_review_web_sg.id] #The app server can only receive traffic from the web server security group
  }

  egress {
    from_port   = 0
    to_port     = 65355
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "book_review_db_sg" { #Database Security Group
  name        = "Allow_db_traffic"
  description = "Allow inbound db traffic"
  vpc_id      = aws_vpc.book-review-demo-vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.book_review_app_sg.id] #The Database server can only receive traffic from the app server security group
  }

  egress {
    from_port   = 0
    to_port     = 65355
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
