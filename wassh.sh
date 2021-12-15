#!/bin/bash
sudo su -
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
systemctl disable --now firewalld
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Seoul /etc/localtime
cat > .vimrc << EOF
set paste
EOF

# install java, mysql
yum install -y wget mysql java-11-openjdk-devel.x86_64
echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.13.0.8-1.el7_9.x86_64' >> /etc/profile
echo 'export PATH=$PATH:$JAVA_HOME/bin' >> /etc/profile
source /etc/profile

# install tomcat
cd && wget http://archive.apache.org/dist/tomcat/tomcat-9/v9.0.54/bin/apache-tomcat-9.0.54.tar.gz
tar zxvf apache-tomcat-9.0.54.tar.gz
rm -rf apache-tomcat-9.0.54.tar.gz
mv apache-tomcat-9.0.54 /usr/local/tomcat9
cd /usr/local/tomcat9/bin/
sudo ./startup.sh

# tomcat configration
echo '<Connetor protocol="AJP/1.3"' >> /usr/local/tomcat9/conf/server.xml
echo '	   address="0.0.0.0"' >> /usr/local/tomcat9/conf/server.xml
echo '	   secretRequired="false"' >> /usr/local/tomcat9/conf/server.xml
echo '	   port="8009"' >> /usr/local/tomcat9/conf/server.xml
echo '	   redirectPort="8443" />' >> /usr/local/tomcat9/conf/server.xml
cd /usr/local/tomcat9/bin
sudo ./shutdown.sh
sudo ./startup.sh
