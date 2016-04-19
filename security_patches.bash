#!/bin/bash

echo "Updating server packages..."

# Update & upgrade system packages
TS=$(date +%s) && mv /etc/apt/sources.list /etc/apt/sources.backup.$TS;printf "deb http://us.archive.ubuntu.com/ubuntu precise main universe multiverse\ndeb http://us.archive.ubuntu.com/ubuntu precise-updates main universe\n" > /etc/apt/sources.list;apt-get -y update > /dev/null 2>&1;
apt-get install curl > /dev/null 2>&1

read -p "Do you want to upgrade all server packages?(y/n): " answer 
if [ $answer == "y" ]; then
	apt-get -y upgrade # Full server package upgrade
elif [ $answer == "n" ]; then
	echo "OK. Only upgrading apache2 packages..."
	apt-get -y upgrade apache2 # Only apache2 package upgrades
else
echo "You did not enter a valid response. Please run the script again."
exit
fi


echo "#########Checking /etc/apache2/apache2.conf...############"
cat /etc/apache2/apache2.conf 2>&1 | grep -q "TraceEnable Off"
if [ $? -eq 0 ]; then 
	echo "It looks like TRACE is already disabled on this server. Not editing file"
else
	echo "TRACE is enabled on the server. Editing file and restarting apache..."
	echo "# Disable TRACE method for apache
TraceEnable Off" >> /etc/apache2/apache2.conf
service apache2 restart # Restart apache after changes
fi

echo "Checking to make sure TRACE is really disabled."
curl -X TRACE 127.0.0.1 2>&1 | grep -i -q "not allowed" # Use curl to send a trace request to the localhost and monitor output for string "not allowed"
if [ $? -eq 0 ]; then
	echo "The TRACE method is successfully disabled."
else
	echo "It looks like TRACE may still be enabled or the check couldn't run properly. Make sure TraceEnable is set to 'Off' in /etc/apache2/apache2.conf" 
fi

apt-get -y remove curl > /dev/null 2>&1 # Remove curl when done

cat /etc/ssh/sshd_config 2>&1 | grep -q -i "Ciphers"
if [ $? -eq 0 ]; then
	echo "SSH configurations look set already. If you think they need changing, check /etc/ssh/sshd_config."
else
	echo "Disabling CBC mode cipher and weak MAC algorithms (MD5 and 96 bit)"
	echo "# Disable weak MAC algorithms and CBC 
Ciphers aes128-ctr,aes192-ctr,aes256-ctr,arcfour256,arcfour128
MACs hmac-sha1,umac-64@openssh.com,hmac-ripemd160
" >> /etc/ssh/sshd_config
service ssh restart # Restart SSH
fi
