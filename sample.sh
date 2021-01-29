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
*)
  echo "Invalid entry "
  ;;
esac