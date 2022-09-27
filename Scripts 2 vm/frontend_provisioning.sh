#!/bin/bash


echo "------------Installing node------------"
cd ~
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt install -y nodejs

node -v 
npm -v

#Clone repo

if [ ! -d ./microservice-app-example ]; then
	cd ~
	git clone https://github.com/bortizf/microservice-app-example.git
	cd ./microservice-app-example/frontend
    pwd
fi

# install dependencies
npm install module node-sass@4.7.2 --unsafe-perm
npm install

#Install Java & Zipkin


echo "------------Installing JAVA------------"
sudo apt install openjdk-8-jdk -y
touch /etc/profile.d/java.sh
echo '''export JAVA_HOME='/usr/lib/jvm/java-8-openjdk-amd64'
export PATH='$JAVA_HOME'/bin:'$PATH'''' | sudo tee -a /etc/profile.d/java.sh
source /etc/profile.d/java.sh
echo $JAVA_HOME

echo "------------Installing Zipkin------------"
curl -sSL https://zipkin.io/quickstart.sh | bash -s
java -jar zipkin.jar > /dev/message-logs 2>&1 &


# build application
npm run build

PORT=8080 AUTH_API_ADDRESS=http://172.16.0.15:8000 TODOS_API_ADDRESS=http://172.16.0.20:8082 npm start
