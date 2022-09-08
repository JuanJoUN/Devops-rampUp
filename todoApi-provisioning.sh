#!/bin/bash

#Download and install node

#if  [ ! -f '/usr/bin/node' ] ;then

    #echo "---------------------------------Installing Node---------------------------------"
    #curl -fsSL https://deb.nodesource.com/setup_8.x | sudo -E bash -
    #sudo apt-get install -y nodejs
    #node -v ; npm -v

#fi

echo"------------Installing node------------"
cd ~
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt install nodejs
node -v

#curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
#export NVM_DIR="~/.nvm"
#[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
#nvm install v8.17.0
#node -v
npm -v

#Clone repo

if [ ! -d ./microservice-app-example ]; then
	cd ~
	git clone https://github.com/bortizf/microservice-app-example.git
fi

#Build microservice
cd ./microservice-app-example/todos-api
pwd

npm install

#Install Java & Zipkin


echo "------------Installing JAVA------------"
sudo apt install openjdk-8-jdk -y
#echo export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 | sudo tee -a /etc/environment
touch /etc/profile.d/java.sh
echo '''export JAVA_HOME='/usr/lib/jvm/java-8-openjdk-amd64'
export PATH='$JAVA_HOME'/bin:'$PATH'''' | sudo tee -a /etc/profile.d/java.sh
source /etc/profile.d/java.sh
#source /etc/environment
echo $JAVA_HOME

echo "------------Installing Zipkin------------"
curl -sSL https://zipkin.io/quickstart.sh | bash -s
java -jar zipkin.jar > /dev/message-logs 2>&1 &

#Install pm2

echo "-------------Installing pm2-------------"
npm install pm2 -g

#Run microservice


pm2 start "REDIS_HOST=172.16.0.25 REDIS_PORT=6379 JWT_SECRET=PRFT TODO_API_PORT=8082 npm start" --watch --listen-timeout 2000