import smtplib
from datetime import datetime

'''
Load .env
'''
import os

# from dotenv import load_dotenv
# load_dotenv(dotenv_path='.env')
smdhc_mail_host = os.environ.get('SMTP_ADDRESS', '')
smdhc_mail_port = os.environ.get('SMTP_PORT', '')
smdhc_mail_user = os.environ.get('SMTP_USERNAME', '')
smdhc_mail_pwd = os.environ.get('SMTP_PASSWORD', '')
smdhc_mail_sender = os.environ.get('SYSTEM_MAIL_FROM', '')
smdhc_mail_receiver = os.environ.get('SYSTEM_MAIL_TO', '')

# SMDHC_SOURCE_SEND_EMAIL_SCRIPT = os.environ.get('SMDHC_SOURCE', '') + '/send-email.py'

# SMDHC_OUTPUT_FOLDER_PATH = '/home/root/app/log/smdhc'
# SMDHC_OUTPUT_HEALTHCHECKS_FOLDER_PATH = os.environ.get('SMDHC_OUTPUT_FOLDER_PATH', SMDHC_OUTPUT_FOLDER_PATH) + '/healthchecks'
# SMDHC_OUTPUT_ARCHIVE_FOLDER_PATH = os.environ.get('SMDHC_OUTPUT_FOLDER_PATH', SMDHC_OUTPUT_FOLDER_PATH) + '/archive'

# SMDHC_CLIENT_LOG_FOLDER_PATH = '/home/root/app/log'
# SMDHC_CLIENT_LOG_FILE_PATH = os.environ.get('SMDHC_CLIENT_LOG_FOLDER_PATH', SMDHC_CLIENT_LOG_FOLDER_PATH) + '/production.log'

# SMDHC_CLIENT_NAME = 'Rails'

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
import socket
hostname = socket.gethostname()

now = datetime.now()
now_string = now.strftime('%d/%m/%Y %H:%M:%S')
service = os.environ.get('SMDHC_CLIENT_NAME', hostname)
subject = "Health Check: " + service

'''
Email vars
'''
smtp_server = os.environ.get('SMDHC_MAIL_HOST', smdhc_mail_host)
port = os.environ.get('SMDHC_MAIL_PORT', smdhc_mail_port)
login = os.environ.get('SMDHC_MAIL_USER', smdhc_mail_user)
password = os.environ.get('SMDHC_MAIL_PWD', smdhc_mail_pwd)

sender = os.environ.get('SMDHC_MAIL_SENDER', smdhc_mail_sender)
receiver = os.environ.get('SMDHC_MAIL_RECEIVER', smdhc_mail_receiver)

message = """\
Subject: {}
To: {}
From: {}

System status summary:

Date: {}
Hostname: {}
Log: {}

{}""".format(subject, receiver, sender, now_string, hostname, logFilePath, logFileRead)

print("smtp_server: " + smtp_server)
print("port: " + port)
print("message: " + message)

'''
Send email
'''
try:
    server = smtplib.SMTP_SSL(smtp_server, port)
    # server = smtplib.SMTP(smtp_server, port)
    server.login(login, password)
    server.sendmail(sender, receiver, message)
    server.quit()

    print('Email sent to {} at {}'.format(receiver, now_string))
except smtplib.SMTPServerDisconnected:
    print('Failed to connect to the server. Wrong user/password?')
except smtplib.SMTPException as e:
    print('SMTP error occurred: ' + str(e))