#!/bin/bash

#Download and install Go 1.18.2

if [ ! -d /usr/local/go ]; then
	curl -OL https://golang.org/dl/go1.18.2.linux-amd64.tar.gz
	sudo tar -C /usr/local -xvf go1.18.2.linux-amd64.tar.gz
	echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.profile
	source ~/.profile
	go version
fi

#Clone microservice repo

if [ ! -d ./microservice-app-example ]; then
	cd /home/vagrant/
	git clone https://github.com/bortizf/microservice-app-example.git
fi

#Run microservice

cd ./microservice-app-example/auth-api
pwd
export GO111MODULE=on
go mod init github.com/bortizf/microservice-app-example/tree/master/auth-api
go mod tidy
echo "Go build"
go build 

#Run microservice

JWT_SECRET=PRFT AUTH_API_PORT=8000 USERS_API_ADDRESS=http://172.16.0.10:8083 ./auth-api > /dev/auth-logs 2>&1 &