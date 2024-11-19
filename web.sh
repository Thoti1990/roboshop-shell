#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "Script started and executed at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2...  $R FAILED $N"
        exit 1
    else
        echo -e "$2...  $G SUCCESS $N"
    fi
}

ID=$(id -u)
if [ $ID -ne 0 ]
then 
    echo -e  "$R ERROR:: plese run with root user $N"
    exit 1
else
    echo "you are in root user"
fi

dnf install nginx -y  &>> $LOGFILE

VALIDATE $? "installing nginx"

systemctl enable nginx &>> $LOGFILE

VALIDATE $? "Enablling nginx"

systemctl start nginx &>> $LOGFILE

VALIDATE $? "Starting nginx"

rm -rf /usr/share/nginx/html/* &>> $LOGFILE

VALIDATE $? "Removed defult website"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE

VALIDATE $? "download web application"

cd /usr/share/nginx/html &>> $LOGFILE

VALIDATE $? "moving nginx html directory"

unzip -o /tmp/web.zip &>> $LOGFILE

VALIDATE $? "unzip web"

cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOGFILE

VALIDATE $? "copied roboshop reverse proxy config"

systemctl restart nginx  &>> $LOGFILE

VALIDATE $? "Restating nginx"