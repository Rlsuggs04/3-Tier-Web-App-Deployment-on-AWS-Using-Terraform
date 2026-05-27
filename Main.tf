#Creating an RDS instance. This is the database layer of our 3-tier architecture. It will be placed in the private subnets, and will only be accessible from the app server security group.
resource "aws_db_instance" "mysql_db_instance" {
  allocated_storage      = 20
  db_name                = "mysql_db_instance"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro" #Elgible for free tier
  username               = "admin"       #Should use variables or a secrets manager in production, but hardcoding for demo purposes
  password               = "password"    #Should use variables or a secrets manager in production, but hardcoding for demo purposes
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true                                      #Prevents errors during quick testing & deletion
  vpc_security_group_ids = [aws_security_group.book_review_db_sg.id] #Only allow access from the DB server security group
  db_subnet_group_name   = aws_db_subnet_group.mysql_subnet_group.id #Connecting it to the DB subnet group, which tells RDS where it can place the database
  publicly_accessible    = false                                     #Ensures the database is not directly accessible from the internet for security. In a production environment, you would typically set this to false and place the database in private subnets with no direct internet access, while allowing access from the app server security group for communication between the app server and database.

  tags = {
    Name = "MySQL DB Instance"
  }
}

#Creating key pairs for SSH access to the EC2 instances. This is required to connect to the app server for configuration and testing.
resource "aws_key_pair" "app_server_key" {
  key_name   = "app-server-key"
  public_key = file("/Users/fwayrob/Cloud Projects/3-Tier-Web-App-Deployment-on-AWS-Using-Terraform/3 Tier Architecture Key.pub") #Replace with your own public key for secure access. In a production environment, you would typically generate a key pair and store the private key securely, while using the public key here for access.    

  tags = {
    Name = "App Server Key"
  }
}

#Creating VM's for the web & app servers. 
resource "aws_instance" "web-server" {                  #Web server instance. This will serve the frontend of our application and will be placed in the public subnet so it can be accessed from the internet for testing and configuration. In a production environment, you would typically place this behind a load balancer and use auto-scaling groups for high availability and scalability.
  ami                         = "ami-0236922087fa98b6e" #Amazon Linux 2 AMI (HVM), SSD Volume Type - us-east-1
  instance_type               = "t3.micro"              #Eligible for free tier
  key_name                    = aws_key_pair.app_server_key.key_name
  vpc_security_group_ids      = [aws_security_group.book_review_web_sg.id]    #Only allow access from the web server security group
  subnet_id                   = aws_subnet.book-review-demo-subnet-public1.id #Placing the web server in the public subnet so it can be accessed from the internet for testing and configuration. 
  associate_public_ip_address = true

  tags = {
    Name = "Web Server"
  }
}

resource "aws_eip" "app-eip" {
  instance = aws_instance.app-server.id
  domain   = "vpc"
}

resource "aws_instance" "app-server" {                  #App server instance. This will serve the backend of our application and will be placed in the public subnet so it can be accessed from the internet for testing and configuration. In a production environment, you would typically place this behind a load balancer and use auto-scaling groups for high availability and scalability.
  ami                         = "ami-0236922087fa98b6e" #Amazon Linux 2 AMI (HVM), SSD Volume Type - us-east-1
  instance_type               = "t3.micro"              #Eligible for free tier
  key_name                    = aws_key_pair.app_server_key.key_name
  vpc_security_group_ids      = [aws_security_group.book_review_app_sg.id]      #Only allow access from the app server security group
  subnet_id                   = aws_subnet.book-review-demo-subnet-public1.id #Placing the app server in the public subnet so it can be accessed from the internet for testing and configuration. In a production environment, you would typically place this behind a load balancer and use auto-scaling groups for high availability and scalability.
  associate_public_ip_address = true

  tags = {
    Name = "App Server"
  }
}