#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

MONGODB_HOST=mongodb.devopsaws.site

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "Script started and executed at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ...  $R FAILED $N"
        exit 1
    else 
        echo -e "$2 ... $G SUCCESS $N"
    fi
}
ID=$(id -u)

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: Plese run with root user $N"
    exit 1
else
    echo "you are in root user"
fi

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "DIsable nodejs"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "Enable nodejs:18 vertion"

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "Installing nodejs"

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? " creating roboshop user"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p /app &>> $LOGFILE

VALIDATE $? "creating app directary"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

VALIDATE $? "download catalogue application"

cd /app 

unzip -o /tmp/catalogue.zip &>> $LOGFILE

VALIDATE $? "unzipping catalogue "

npm install  &>> $LOGFILE

VALIDATE $? "installing dependancies"

cp -o /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE

VALIDATE $? "copying catalogue service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Daemon reload catalogue"

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "Enablling  catalogue"

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "Start catalogue"

cp -o /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE 

VALIDATE $? "Copying mongo repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installing mongodb client"

mongo --host $MONGODB_HOST </app/schema/catalogue.js &>> $LOGFILE

VALIDATE $? "Loading catalogue data into mongodb "



