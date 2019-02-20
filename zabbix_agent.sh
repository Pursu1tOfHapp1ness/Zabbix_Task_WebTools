yum install http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm -y
yum install zabbix-agent -y
systemctl start zabbix-agent
sed -i 's/#DebugLevel=3/DebugLevel=3/' /etc/zabbix/zabbix_agentd.conf
sed -i 's/# ListenPort=10050/ListenPort=10050/' /etc/zabbix/zabbix_agentd.conf
sed -i 's/# ListenIP=0.0.0.0/ListenIP=0.0.0.0/' /etc/zabbix/zabbix_agentd.conf
sed -i 's/# StartAgents=3/StartAgents=3/' /etc/zabbix/zabbix_agentd.conf
sed -i 's/# HostnameItem=system.hostname/HostnameItem=system.hostname/' /etc/zabbix/zabbix_agentd.conf 
sed -i 's/Server=127.0.0.1/Server=192.168.55.55/' /etc/zabbix/zabbix_agentd.conf
sed -i 's/ServerActive=127.0.0.1/ServerActive=192.168.55.55/' /etc/zabbix/zabbix_agentd.conf
service zabbix-agent restart

#Install OracleJDK for application
wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.rpm"
yum install jdk-8u131-linux-x64.rpm -y
#Download and install TOMCAT
yum install unzip  -y 
wget http://ftp.byfly.by/pub/apache.org/tomcat/tomcat-8/v8.5.37/bin/apache-tomcat-8.5.37.zip
unzip apache-tomcat-8.5.37.zip

if [ ! -d /var/lib/tomcat ]; then mkdir -p /var/lib/tomcat; else echo "Such directory is existed! ";fi

cp -rf ./apache-tomcat-8.5.37/* /var/lib/tomcat/
chmod +x /var/lib/tomcat/bin/*.sh

#Deploy our application
if [ ! -f /var/lib/tomcat/webapps/TestApp.war ]; then cp /vagrant/TestApp.war /var/lib/tomcat/webapps; else echo "This application is already deployed! ";fi
if [ ! -f /var/lib/tomcat/lib/gson-2.8.1.jar ]; then cp /vagrant/gson-2.8.1.jar /var/lib/tomcat/lib; else echo "Such library gson-2.8.1.jar is already existed! ";fi
if [ ! -f /var/lib/tomcat/webapps/jstl-1.2.jar ]; then cp /vagrant/jstl-1.2.jar /var/lib/tomcat/lib; else echo "Such library jstl-1.2.jar is already existed! ";fi
chown vagrant: -R /var/lib/tomcat/	
sed -i '/<servlet-class>com.epam.nix.java.testapp.servlet.GenericServlet<\/servlet-class>/a<multipart-config>\n<location>\/tmp<\/location>\n<max-file-size>20848820</\max-file-size>\n<max-request-size>418018841<\/max-request-size>\n<file-size-threshold>1048576<\/file-size-threshold>\n</\multipart-config>' /var/lib/tomcat/webapps/TestApp/WEB-INF/web.xml
sleep 3

#Start tomcat
/var/lib/tomcat/bin/startup.sh