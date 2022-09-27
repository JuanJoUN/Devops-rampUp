#!/bin/bash

export ec2IP = "$(hostname -I | awk '{print $1}')"

#***********User Api*************

#Install java JDK 8

sudo add-apt-repository -y ppa:openjdk-r/ppa
sudo apt-get update
sudo apt-get install -y openjdk-8-jdk
sudo touch /etc/profile.d/java.sh
echo '''export JAVA_HOME='/usr/lib/jvm/java-8-openjdk-amd64'
export PATH='$JAVA_HOME'/bin:'$PATH'''' | sudo tee -a /etc/profile.d/java.sh
source /etc/profile.d/java.sh
echo $JAVA_HOME

#Clone repo

if [ ! -d "./microservice-app-example" ]; then
	cd ~
	git clone https://github.com/bortizf/microservice-app-example.git
fi

#Build microservice

cd ./microservice-app-example/users-api
pwd
./mvnw clean install

#Install pm2

echo "-------------Installing pm2-------------"
sudo npm install pm2 -g

#Run microservice

pm2 start "JWT_SECRET=PRFT SERVER_PORT=8083 java -jar target/users-api-0.0.1-SNAPSHOT.jar" --listen-timeout 1000

#***********Auth Api*************

#Download and install Go 1.18.2



if [ ! -d /usr/local/go ]; then
	cd ~
	sudo apt install -y snapd
	sudo snap install go --classic --channel=1.18/stable
	# curl -OL https://golang.org/dl/go1.18.2.linux-amd64.tar.gz
	# sudo tar -C /usr/local -xvf go1.18.2.linux-amd64.tar.gz
	# echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.profile
	# source ~/.profile
	go version
	whereami
fi

#Run microservice

cd ./microservice-app-example/auth-api
pwd
export GO111MODULE=on
/usr/local/go/bin/go mod init github.com/bortizf/microservice-app-example/tree/master/auth-api
/usr/local/go/bin/go mod tidy
echo "Go build"
/usr/local/go/bin/go build 

#Run microservice

pm2 start "JWT_SECRET=PRFT AUTH_API_PORT=8000 USERS_API_ADDRESS='$ec2IP:8083' ./auth-api"

#***********Log Message*************

#Download and install python and Redis

cd ~
curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
sudo apt-get update
sudo apt-get install -y redis
sudo apt install -y python3-pip

#Install node

echo "------------Installing node------------"

cd ~
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt install -y nodejs
node -v

#Build microservice

cd ~/microservice-app-example/log-message-processor
pwd
pip3 install -r requirements.txt

#Run microservice

sudo kill -9 $(sudo lsof -t -i:6379)
sudo /etc/init.d/redis-server stop
redis-server --protected-mode no > /dev/redis-logs 2>&1 &

pm2 start "REDIS_HOST=$ec2IP REDIS_PORT=6379 REDIS_CHANNEL=log_channel python3 main.py" --listen-timeout 1000

#***********Todo Api*************

#Build microservice
cd ~/microservice-app-example/todos-api
pwd

npm install

#Install Zipkin

echo "------------Installing Zipkin------------"
curl -sSL https://zipkin.io/quickstart.sh | bash -s
java -jar zipkin.jar > /dev/message-logs 2>&1 &

#Run microservice

REDIS_HOST='$ec2IP' REDIS_PORT=6379 JWT_SECRET=PRFT TODO_API_PORT=8082 npm start



