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

print("logFilePath: " + logFilePath)

'''
Email content vars
'''
import socket
hostname = socket.gethostname()

now = datetime.now()
now_string = now.strftime('%d/%m/%Y %H:%M:%S')
service = os.environ.get('SMDHC_CLIENT_NAME', '')
env = os.environ.get('SMDHC_CLIENT_ENV', '')
subject = "Health Check: " + env + " " + service + " (" + hostname + ")"

'''
Email vars (smdhc)
'''
smdhc_smtp_server = os.environ.get('SMDHC_MAIL_HOST', '')
smdhc_port = os.environ.get('SMDHC_MAIL_PORT', '')
smdhc_login = os.environ.get('SMDHC_MAIL_USER', '')
smdhc_password = os.environ.get('SMDHC_MAIL_PWD', '')

smdhc_sender = os.environ.get('SMDHC_MAIL_SENDER', '')
smdhc_receiver = os.environ.get('SMDHC_MAIL_RECEIVER', '')

'''
Email vars (existing env)
'''
smtp_server = os.environ.get('SMTP_ADDRESS', smdhc_smtp_server)
port = os.environ.get('SMTP_PORT', smdhc_port)
login = os.environ.get('SMTP_USERNAME', smdhc_login)
password = os.environ.get('SMTP_PASSWORD', smdhc_password)

sender = os.environ.get('SYSTEM_MAIL_FROM', smdhc_sender)
receiver = os.environ.get('SYSTEM_MAIL_TO', smdhc_receiver)


formatMessage = """\
Subject: {}
To: {}
From: {}


System status summary:

Date: {}
Hostname: {}
Log: {}

{}""".format(subject, receiver, sender, now_string, hostname, logFilePath, logFileRead)

if service == "WALLETD":
    message = formatMessage.decode('ascii', 'ignore').encode('ascii')
elif service == "TBOT":
    message = formatMessage.encode("ascii", "ignore")
else:
    import sys
    reload(sys)
    sys.setdefaultencoding('utf8')
    message = formatMessage.encode('utf-8')

print("smtp_server: " + smtp_server)
# print("port: " + port)
# print("message: " + message)

'''
Send email
'''
try:
    #server = smtplib.SMTP_SSL(smtp_server, port)
    server = smtplib.SMTP(smtp_server, port)
    server.starttls()
    server.login(login, password)
    server.sendmail(sender, receiver, message)
    server.quit()

    print('Email sent to {} at {}'.format(receiver, now_string))
except smtplib.SMTPServerDisconnected:
    print('Failed to connect to the server. Wrong user/password?')
except smtplib.SMTPException as e:
    print('SMTP error occurred: ' + str(e))