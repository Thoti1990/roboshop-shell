#!/bin/bash

R="\e[31m"
G="\e[32m"
B="\e[34m"
N="\e[0m"
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo  "script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATION(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$2  ...$R FAILED $N"
        exit 1
    else
        echo -e "$2  ...$G SUCCESS $N"
    fi
}

ID=$(id -u)

if [ $ID -ne 0 ] 
then 
    echo -e "$R ERROR:: please run with root user $N"
    exit 1
else
    echo "you are in root user"
fi

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATION $? "copied mongodb repo" 

dnf install mongodb-org -y &>> $LOGFILE

VALIDATION $? "Installing mongodb"

systemctl enable mongod &>> $LOGFILE

VALIDATION $? "enabling mongodb"

systemctl start mongod &>> $LOGFILE

VALIDATION $? "starting mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE

VALIDATION $? "remote access to mongodb"

systemctl restart mongod &>> $LOGFILE

VALIDATION $? "restated mongod "