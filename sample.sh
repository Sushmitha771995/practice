#!/bin/bash
echo -e "\e[35mfrontend\e[0m"
echo -e "\e[34mInstalling Nginx\e[0m"
yum install nginx -y &>> /tmp/outfile
if [$? == 0 ]
then
echo -e "\t\t\t\t\t\e[32mSUCCESS\e[0m"
else
echo -e "\t\t\t\t\t\e[32mFailure\e[0m"
exit
fi
echo -e "\e[34mDownloading frontend docs\e[0m"
if [$? == 0 ]
then
echo -e "\t\t\t\t\t\e[32mSUCCESS\e[0m"
else
echo -e "\t\t\t\t\t\e[32mFailure\e[0m"
exit
fi
curl -s -L -o /tmp/frontend.zip "https://dev.azure.com/DevOps-Batches/f4b641c1-99db-46d1-8110-5c6c24ce2fb9/_apis/git/repositories/a781da9c-8fca-4605-8928-53c962282b74/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true" &>> /tmp/outfile
echo -e "\e[34mSetting up frontend\e[0m"
cd /usr/share/nginx/html
rm -rf *
unzip /tmp/frontend.zip &>> /tmp/outfile
mv static/* .
rm -rf static README.md doc* DOC* Azu* &>> /tmp/outfile
if [$? == 0 ]
then
echo -e "\t\t\t\t\t\e[32mSUCCESS\e[0m"
else
echo -e "\t\t\t\t\t\e[32mFailure\e[0m"
exit
fi
echo -e "\e[34mSetting up configuration\e[0m"
mv localhost.conf /etc/nginx/default.d/roboshop.conf
echo -e "\t\t\t\t\t\e[32mSUCCESS\e[0m"
echo -e "\e[34mStarting frontend\e[0m"
systemctl enable nginx
systemctl start nginx
if [$? == 0 ]
then
echo -e "\t\t\t\t\t\e[32mSUCCESS\e[0m"
else
echo -e "\t\t\t\t\t\e[32mFailure\e[0m"
exit
fi