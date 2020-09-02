import smtplib
from datetime import datetime

'''
Load .env
'''
import os

# from dotenv import load_dotenv
# load_dotenv(dotenv_path='.env')

'''
Load args
'''
import sys 
arg = sys.argv[1]
# print(arg)

'''
Read file
'''
logFilePath = arg
logFile = open(logFilePath, 'r+')
logFileRead = logFile.read()

# import subprocess
# subprocess.run(["pm2", "ls"])

'''
Email content vars
'''
now = datetime.now()
now_string = now.strftime('%d/%m/%Y %H:%M:%S')
service = os.environ.get('SMDHC_APPLICATION_NAME', '')
subject = "Health Check: " + service

import socket
hostname = socket.gethostname()

'''
Email vars
'''
port = os.environ.get('SMDHC_MAIL_PORT', '')
smtp_server = os.environ.get('SMDHC_MAIL_HOST', '')
login = os.environ.get('SMDHC_MAIL_USER', '')
password = os.environ.get('SMDHC_MAIL_PWD', '')

sender = os.environ.get('SMDHC_MAIL_SENDER', '')
receiver = os.environ.get('SMDHC_MAIL_RECEIVER', '')

message = """\
Subject: {}
To: {}
From: {}

System status summary:

Date: {}
Hostname: {}
Log: {}

{}""".format(subject, receiver, sender, now_string, hostname, logFilePath, logFileRead)

'''
Send email
'''
try:
    server = smtplib.SMTP_SSL(smtp_server, port)
    # server = smtplib.SMTP(smtp_server, port)
    server.login(login, password)
    server.sendmail(sender, receiver, message)
    server.quit()

    print('Email sent at {}'.format(now_string))
except smtplib.SMTPServerDisconnected:
    print('Failed to connect to the server. Wrong user/password?')
except smtplib.SMTPException as e:
    print('SMTP error occurred: ' + str(e))