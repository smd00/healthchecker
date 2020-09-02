import smtplib
from datetime import datetime

import sys 
arg = sys.argv[1]
# print(arg)

logFilePath = arg
logFile = open(logFilePath, 'r+')
logFileRead = logFile.read()

# import subprocess
# subprocess.run(["pm2", "ls"])

now = datetime.now()
now_string = now.strftime('%d/%m/%Y %H:%M:%S')
service = 'Rails'
subject = "Health Check: " + service

import socket
hostname = socket.gethostname()

port = 25
smtp_server = 'smtp.mailtrap.io'
login = '111111111111'
password = '111111111111'

sender = 'Health Checker <no-reply@healthchecker.test>'
receiver = 'Admin <admin@healthchecker.test>'

message = """\
Subject: {}
To: {}
From: {} 

System status summary:

Date: {}
Hostname: {}
Log: {}

{}""".format(subject, receiver, sender, now_string, hostname, logFilePath, logFileRead)

try:
    server = smtplib.SMTP(smtp_server, port)
    server.login(login, password)
    server.sendmail(sender, receiver, message)
    server.quit()

    print('Email sent at {}'.format(now_string))
except smtplib.SMTPServerDisconnected:
    print('Failed to connect to the server. Wrong user/password?')
except smtplib.SMTPException as e:
    print('SMTP error occurred: ' + str(e))