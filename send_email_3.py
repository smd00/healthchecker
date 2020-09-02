import smtplib
from datetime import datetime
from socket import gaierror

import sys 
arg = sys.argv[1]
# print(arg)

logFilePath = arg
logFile = open(logFilePath, "r+")
logFileRead = logFile.read()

now = datetime.now()
now_string = now.strftime("%d/%m/%Y %H:%M:%S")
service = "Rails"
subject = "Health Check: " + service

import socket
hostname = socket.gethostname()

port = 25
smtp_server = 'smtp.mailtrap.io'
login = '111111111111'
password = '111111111111'

sender = 'Health Checker <no-reply@healthchecker.test>'
receiver = 'Admin <admin@healthchecker.test>'

message = f"""\
Subject: {subject}
To: {receiver}
From: {sender} 

System status summary:

Date: {now_string}
Hostname: {hostname}

{logFileRead}"""

try:
    with smtplib.SMTP(smtp_server, port) as server:
        server.login(login, password)
        server.sendmail(sender, receiver, message)

    print('Sent')
except (gaierror, ConnectionRefusedError):
    print('Failed to connect to the server. Bad connection settings?')
except smtplib.SMTPServerDisconnected:
    print('Failed to connect to the server. Wrong user/password?')
except smtplib.SMTPException as e:
    print('SMTP error occurred: ' + str(e))