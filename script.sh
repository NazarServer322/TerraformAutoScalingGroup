#!/bin/bash
yum -y update
sudo yum update -y
sudo amazon-linux-extras install docker -y 
sudo service docker start
sudo usermod -a -G docker ec2-user

 sudo docker pull nazarserver/shoptest
 sudo docker run -d --restart=always -p 80:80 --name market nazarserver/shoptest
