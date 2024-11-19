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

dnf module disable mysql -y &>> $LOGFILE

VALIDATE $? "disable current version of mysql"

cp mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE

VALIDATE $? "copping mysql repo"

dnf install mysql-community-server -y &>> $LOGFILE

VALIDATE $? "installing mysql server"

systemctl enable mysqld &>> $LOGFILE

VALIDATE $? "enabled mysqld"

systemctl start mysqld &>> $LOGFILE

VALIDATE $? "started mysqld"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE

VALIDATE $? "setting mysql root password"