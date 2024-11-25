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


dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "Disable nodejs "

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "Enablling nodejs:18"

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "Installing nodejs"

id roboshop
if [ $? -ne 0 ]
then 
    useradd roboshop
    VALIDATE $? "creating roboshop user"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p /app &>> $LOGFILE

VALIDATE $? "creating app directory"

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE

VALIDATE $? "Downloding user application"

cd /app 

unzip -o /tmp/user.zip &>> $LOGFILE

VALIDATE $? "unzipping user"

npm install &>> $LOGFILE

VALIDATE $? "Installing dependencess"

cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service &>> $LOGFILE

VALIDATE $? "copping user service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "user daemon reload"

systemctl enable user &>> $LOGFILE

VALIDATE $? "user enabling "

systemctl start user &>> $LOGFILE

VALIDATE $? "Start user"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "copping mongo repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installing mongodb client"

mongo --host $MONGODB_HOST </app/schema/user.js &>> $LOGFILE

VALIDATE $? "loading user data into mongoDB"