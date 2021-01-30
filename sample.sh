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
user_add()
{
 id -u roboshop &>/dev/null
case $? in
0)
  ;;
*)
useradd roboshop  &>> $LOG_FILE
;;
esac
}

app_service() {
echo -n -e "\e[34mInstalling node js\e[0m\t\t"
yum install nodejs make gcc-c++ -y &>> $LOG_FILE
status
echo -n -e "\e[34mDownloading catalogue dependcines\e[0m\t"
curl -s -L -o /tmp/$COMPONENT.zip $1 &>> $LOG_FILE
cd /home/roboshop &>> $LOG_FILE
mkdir -p $COMPONENT &>> $LOG_FILE
cd $COMPONENT &>> $LOG_FILE
unzip  -o /tmp/$COMPONENT.zip &>> $LOG_FILE
npm install --unsafe-perm &>> $LOG_FILE
status
chown -R roboshop:roboshop /home/roboshop/$COMPONENT &>> $LOG_FILE
echo -n -e "\e[34mUpdate configuration files\e[0m\t\t" &>> $LOG_FILE
mv /home/roboshop/$COMPONENT/systemd.service /etc/systemd/system/$COMPONENT.service &>> $LOG_FILE
systemctl daemon-reload &>> $LOG_FILE
systemctl start $COMPONENT &>> $LOG_FILE
systemctl enable $COMPONENT &>> $LOG_FILE
status
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
app_service "https://dev.azure.com/DevOps-Batches/f4b641c1-99db-46d1-8110-5c6c24ce2fb9/_apis/git/repositories/1a7bd015-d982-487f-9904-1aa01c825db4/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true"
;;
redis)
echo -n -e "\e[34mInstalling Redis\e[0m\t\t"
yum install epel-release yum-utils -y &>> $LOG_FILE
yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y &>> $LOG_FILE
yum-config-manager --enable remi &>> $LOG_FILE
 yum install redis -y &>> $LOG_FILE
 status
echo -n -e "\e[34mUpdate config file\e[0m\t\t"
sed -i 's/127.0.0.1/0.0.0.0/' /etc/$COMPONENT.conf
status
echo -n -e "\e[34mStart Redis service\e[0m\t\t"
systemctl enable redis  &>> $LOG_FILE
systemctl start redis    &>> $LOG_FILE
status
;;
user)

  app_service https://dev.azure.com/DevOps-Batches/f4b641c1-99db-46d1-8110-5c6c24ce2fb9/_apis/git/repositories/360c1f78-e8ed-41e8-8b3d-bdd12dc8a6a1/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true

;;

  cart)
echo -n -e "\e[34mInstalling node js\e[0m\t\t"
yum install nodejs make gcc-c++ -y  &>> $LOG_FILE
status

echo -n -e "\e[34mDownloading $COMPONENT dependcines\e[0m\t"
user_add
curl -s -L -o /tmp/$COMPONENT.zip "https://dev.azure.com/DevOps-Batches/f4b641c1-99db-46d1-8110-5c6c24ce2fb9/_apis/git/repositories/d1ba7cbf-6c60-4403-865d-8a522a76cd76/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true"  &>> $LOG_FILE
cd /home/roboshop
mkdir -p $COMPONENT
cd $COMPONENT
unzip  -o /tmp/$COMPONENT.zip &>> $LOG_FILE
npm install --unsafe-perm  &>> $LOG_FILE
status
chown -R roboshop:roboshop /home/roboshop/$COMPONENT
echo -n -e "\e[34mUpdate configuration files\e[0m\t"
mv /home/roboshop/$COMPONENT/systemd.service /etc/systemd/system/$COMPONENT.service
status
echo -n -e "\e[34mStart $COMPONENT service\e[0m\t\t"
systemctl daemon-reload  &>> $LOG_FILE
systemctl start $COMPONENT    &>> $LOG_FILE
systemctl enable $COMPONENT    &>> $LOG_FILE
status
  ;;

*)
  echo "Invalid entry "
  ;;
esac

