#! /bin/bash

# Install Java
  sudo yum install java-11.0-openjdk.x86_64 -y
  yum install fontconfig java-11-openjdk -y

# Download and Install Jenkins
  yum update -y
  yum install wget -y
  wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
  rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
  yum install jenkins -y
  
# Start Jenkins
# service jenkins start

# Enable Jenkins with systemctl
  systemctl enable jenkins

# Start Jenkins
  systemctl start jenkins

# Install Git SCM
  yum install git -y

# Make sure Jenkins comes up/on when reboot
  chkconfig Jenkins on
