import smtplib
from datetime import datetime

'''
Load .env
'''
import os

# from dotenv import load_dotenv
# load_dotenv(dotenv_path='.env')

SMDHC_MAIL_HOST = os.environ.get('SMTP_ADDRESS', '')
SMDHC_MAIL_PORT = os.environ.get('SMTP_PORT', '')
SMDHC_MAIL_USER = os.environ.get('SMTP_USERNAME', '')
SMDHC_MAIL_PWD = os.environ.get('SMTP_PASSWORD', '')

SMDHC_MAIL_SENDER = os.environ.get('SYSTEM_MAIL_FROM', '')
SMDHC_MAIL_RECEIVER = os.environ.get('SYSTEM_MAIL_TO', '')

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
smtp_server = os.environ.get('SMDHC_MAIL_HOST', SMDHC_MAIL_HOST)
port = os.environ.get('SMDHC_MAIL_PORT', SMDHC_MAIL_PORT)
login = os.environ.get('SMDHC_MAIL_USER', SMDHC_MAIL_USER)
password = os.environ.get('SMDHC_MAIL_PWD', SMDHC_MAIL_PWD)

sender = os.environ.get('SMDHC_MAIL_SENDER', SMDHC_MAIL_SENDER)
receiver = os.environ.get('SMDHC_MAIL_RECEIVER', SMDHC_MAIL_RECEIVER)

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
print("sender: " + sender)
print("receiver: " + receiver)
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