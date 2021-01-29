#!/bin/bash
LOG_FILE=/tmp/outfile
COMPONENT=$1
heading()
{
  echo  -e "\t\t\t\e[35m$COMPONENT\e[0m"
}
status()
{
case $? in
0)
echo -e "\t\t\t\t\e[32mSUCCESS\e[0m"
;;
*)
echo -e "\t\t\t\t\e[32mFailure\e[0m"
exit
;;
esac
}
heading
case $COMPONENT in
frontend)
echo -n -e "\e[34mInstalling Nginx\e[0m\t"
yum install nginx -y &>> $LOG_FILE
status
echo -n -e "\e[34mDownloading frontend docs\e[0m"
status
curl -s -L -o /tmp/frontend.zip "https://dev.azure.com/DevOps-Batches/f4b641c1-99db-46d1-8110-5c6c24ce2fb9/_apis/git/repositories/a781da9c-8fca-4605-8928-53c962282b74/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true" &>> /$LOG_FILE
echo -n -e "\e[34mSetting up frontend\e[0m\t"
cd /usr/share/nginx/html
rm -rf *
unzip /tmp/frontend.zip &>> $LOG_FILE
mv static/* .
rm -rf static README.md doc* DOC* Azu* &>> $LOG_FILE
status
echo -n -e "\e[34mSetting up configuration\e[0m"
mv localhost.conf /etc/nginx/default.d/roboshop.conf
status
echo -n -e "\e[34mStarting frontend\e[0m\t"
systemctl enable nginx
systemctl start nginx
status
;;

mongo)
  echo -n -e "\e[34mSetting up repo\e[0m\t\t\t"
  echo '[mongodb-org-4.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/4.2/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.2.asc' > /etc/yum.repos.d/mongodb.repo
status
echo -n -e "\e[34mInstalling mongo\e[0m\t\t"
yum install -y mongodb-org &>> $LOG_FILE
status
echo -n -e "\e[34mUpdate config file\e[0m\t\t"
sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf
systemctl enable mongod
systemctl start mongod
status
echo -n -e "\e[34mLoad schema\e[0m\t\t\t\t"
curl -s -L -o /tmp/mongodb.zip "https://dev.azure.com/DevOps-Batches/ce99914a-0f7d-4c46-9ccc-e4d025115ea9/_apis/git/repositories/e9218aed-a297-4945-9ddc-94156bd81427/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true" &>> $LOG_FILE
cd /tmp
unzip mongodb.zip      &>> $LOG_FILE
mongo < catalogue.js   &>> $LOG_FILE
mongo < users.js       &>> $LOG_FILE
 status
 ;;
catalogue)
 echo -n -e "\e[34mInstalling node js\e[0m\t\t"
yum install nodejs make gcc-c++ -y  &>> $LOG_FILE
status

echo -n -e "\e[34mDownloading catalogue docs\e[0m\t"
id -u roboshop &>/dev/null
case $? in
0)
  ;;
*)
useradd roboshop  &>> $LOG_FILE
;;
esac
status
curl -s -L -o /tmp/$COMPONENT.zip "https://dev.azure.com/DevOps-Batches/f4b641c1-99db-46d1-8110-5c6c24ce2fb9/_apis/git/repositories/1a7bd015-d982-487f-9904-1aa01c825db4/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true"  &>> $LOG_FILE
status
cd /home/roboshop
status
mkdir -p $COMPONENT
status
cd $COMPONENT
status
unzip  -o /tmp/$COMPONENT.zip &>> $LOG_FILE
status
chown -R roboshop:roboshop /home/roboshop/$COMPONENT
status
npm install  &>> $LOG_FILE
status
echo -n -e "\e[34mUpdate configuration files\e[0m\t\t"
mv /home/roboshop/$COMPONENT/systemd.service /etc/systemd/system/$COMPONENT.service

 systemctl daemon-reload
 systemctl start $COMPONENT
 systemctl enable $COMPONENT
status
;;
*)
  echo "Invalid entry "
  ;;
esac

