#!/bin/bash

#Install java JDK 8

sudo apt install openjdk-8-jdk -y
#echo export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 | sudo tee -a /etc/environment
touch /etc/profile.d/java.sh
echo '''export JAVA_HOME='/usr/lib/jvm/java-8-openjdk-amd64'
export PATH='$JAVA_HOME'/bin:'$PATH'''' | sudo tee -a /etc/profile.d/java.sh
source /etc/profile.d/java.sh
#source /etc/environment
echo $JAVA_HOME

#Clone repo

if [ ! -d "./microservice-app-example" ]; then
	cd /home/vagrant/
	git clone https://github.com/bortizf/microservice-app-example.git
fi

#Build microservice

cd ./microservice-app-example/users-api
pwd
./mvnw clean install

#Run microservice

JWT_SECRET=PRFT SERVER_PORT=8083 java -jar target/users-api-0.0.1-SNAPSHOT.jar > /dev/user-logs 2>&1 &
