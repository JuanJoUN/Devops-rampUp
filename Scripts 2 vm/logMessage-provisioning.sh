#!/bin/bash

#Download and install python and Redis

curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
sudo apt-get update
sudo apt-get install -y redis
sudo apt install -y python3-pip

#Install node

echo "------------Installing node------------"

cd ~
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt install nodejs
node -v

#Clone microservice repo

if [ ! -d ./microservice-app-example ]; then
	cd ~
	git clone https://github.com/bortizf/microservice-app-example.git
fi

#Build microservice

cd ./microservice-app-example/log-message-processor
pwd
pip3 install -r requirements.txt

#Install pm2

echo "-------------Installing pm2-------------"
npm install pm2 -g

#Run microservice

sudo kill -9 $(sudo lsof -t -i:6379)
sudo /etc/init.d/redis-server stop
redis-server --protected-mode no > /dev/redis-logs 2>&1 &

pm2 start "REDIS_HOST=172.16.0.25 REDIS_PORT=6379 REDIS_CHANNEL=log_channel python3 main.py" --listen-timeout 1000