import smtplib
from datetime import datetime

'''
Load .env
'''
import os

# This works with just import os
# print(os.environ['HOME'])
# print(os.getenv('HOME', 'default'))
# print(os.environ)

# # load env - method 1 (https://github.com/theskumar/python-dotenv)
# from dotenv import load_dotenv
# load_dotenv(dotenv_path='.env')

# # load env - method 2 (cryptodash)
# from os import environ, path
# from dotenv import load_dotenv
# basedir = path.abspath(path.dirname(__file__))
# load_dotenv(path.join(basedir, '.env'))

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
service = 'Rails'
subject = "Health Check: " + service

import socket
hostname = socket.gethostname()

'''
Email vars
'''
port = 25
smtp_server = os.environ.get('HEALTHCHECKER_MAIL_HOST', '')
login = os.environ.get('HEALTHCHECKER_MAIL_USER', '')
password = os.environ.get('HEALTHCHECKER_MAIL_PWD', '')

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

'''
Send email
'''
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