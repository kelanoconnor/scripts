# Date: 7/13/2017
# Author: Kelan O'Connor
# In progress: Convert bash script to python program

# This program will check for common Linux server vulnerabilities and attempt to correct them.
from sys import argv
import os

echo ("Updating server packages...")


os.system('TS=$(date +%s) && mv /etc/apt/sources.list /etc/apt/sources.backup.$TS;printf "deb http://us.archive.ubuntu.com/ubuntu precise main universe multiverse\ndeb http://us.archive.ubuntu.com/ubuntu precise-updates main universe\n" > /etc/apt/sources.list;apt-get -y update > /dev/null 2>&1')
os.system('apt-get install curl > /dev/null 2>&1')

echo "Do you want to update all system packages or just Apache?"
update = raw_input("y for all, n for just Apache")

if update == 'y':
    os.system('apt-get -y upgrade') #full server package upgrade
elif update == 'n':
    print "OK. Only upgrading Apache software."
    os.system('apt-get -y upgrade apache2')
else:
    print "Not a valid response. Please run the script again."
    exit(0)

print ("### Checking /etc/apache2/apache2.conf... ###")
os.system('grep /etc/apache2/apache2.conf 2>&1 | grep -q "TraceEnable Off"')
