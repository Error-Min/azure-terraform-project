#!/bin/bash
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
systemctl disable --now firewalld
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Seoul /etc/localtime
cat > .vimrc << EOF
set paste
EOF
yum install -y httpd httpd-devel gcc gcc-c++ wget
systemctl enable --now httpd
cd /var/www/html
wget http://archive.apache.org/dist/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.46-src.tar.gz
tar zxvf tomcat-connectors-1.2.46-src.tar.gz
rm -rf tomcat-connectors-1.2.46-src.tar.gz
cd tomcat-connectors-1.2.46-src/native
./configure --with-apxs=/bin/apxs
make
make install
cd apache-2.0/
cp mod_jk.so /usr/lib64/httpd/modules/mod_jk.so
chmod 755 /usr/lib64/httpd/modules/mod_jk.so
echo 'LoadModule jk_module /usr/lib64/httpd/modules/mod_jk.so' >> /etc/httpd/conf/httpd.conf
echo '     <IfModule jk_module>' >> /etc/httpd/conf/httpd.conf
echo '     	JkWorkersFile conf/workers.properties' >> /etc/httpd/conf/httpd.conf
echo '     	JkLogFile logs/mod_jk.log' >> /etc/httpd/conf/httpd.conf
echo '     	JkShmFile run/mod_jk.shm' >> /etc/httpd/conf/httpd.conf
echo '     	JkLogLevel info' >> /etc/httpd/conf/httpd.conf
echo '     	JkLogStampFormat "[%a %b %d %H:%M:%S %Y]"' >> /etc/httpd/conf/httpd.conf
echo '     	JkMount /* worker1' >> /etc/httpd/conf/httpd.conf
echo '     </IfModule>' >> /etc/httpd/conf/httpd.conf
cat > /etc/httpd/conf/workers.properties << EOF
worker.list=worker1
worker.worker1.type=ajp13
worker.worker1.host=10.0.2.20
worker.worker1.port=8009
EOF
systemctl restart httpd