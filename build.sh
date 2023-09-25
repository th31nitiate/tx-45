#!/usr/bin/env bash
### MAKE SURE TO CHANGE DEFAULT URLS
set -e

BUILD_NAME=TX-45.VRC-3
APP_SERVER=192.168.56.1

echo "[+] Building server: $BUILD_NAME"
echo "[+] OS: $(cat /etc/redhat-release)"
echo "[+] Author: m3rl1n th31nitiate"
echo "[+] Date: $(date)"

cd /tmp

echo "Ensure SELinux is disabled"
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
sestatus

echo "[*] Configure hostname"
hostnamectl --static --pretty set-hostname tx-45.vrc-3

echo "[+] Add user to madnar to system as non root user"
# Add the docker user, ignore encase user already exists on system
if ! grep --quiet 'madnar' /etc/passwd; then
  useradd -s /bin/bash -m madnar
  mkdir -p /home/madnar/.scripts
  mkdir -p /home/madnar/.ssh
  chown madnar:madnar /home/madnar/.ssh
fi

echo "[+] Installing HTTPD server"
dnf groupinstall -y 'Development tools'
dnf groupinstall -y 'Basic Web Server'
dnf install -y xorg-x11-server-Xvfb
dnf install -y open-vm-tools
curl -L http://$APP_SERVER/web.tar.bz -o /tmp/web.tar.bz
tar xvf web.tar.bz


echo "[+] Configuring web server files and service page"
mkdir -p /var/www/html/corpsupport
cp -rf /tmp/web/* /var/www/html/corpsupport/
echo "Only authorized personal should be viewing this site" > /var/www/html/index.html
chown apache:apache -R /var/www/html/
firewall-cmd --add-service=http --permanent
systemctl enable --now httpd

echo "[+] Configure the NFS service"
mkdir -p /srv/nfs/support
cat << EOF > /etc/exports
/srv/nfs/support	*(rw,no_root_squash)
EOF

chown nobody:nobody -R /srv/nfs/support
systemctl enable --now nfs-server

echo "[+] Configure NFS firewall service"
firewall-cmd --add-service=nfs --permanent
firewall-cmd --add-service=mountd --permanent
firewall-cmd --add-service=rpc-bind --permanent
firewall-cmd --reload

echo "[+] Install Libre Office"
curl -L http://$APP_SERVER/LibreOffice_5.4.6.2_Linux_x86-64_rpm.tar.gz -o /tmp/LibreOffice_5.4.6.2_Linux_x86-64_rpm.tar.gz
cd /tmp
tar xvf /tmp/LibreOffice_5.4.6.2_Linux_x86-64_rpm.tar.gz
rpm -Uvh /tmp/LibreOffice_5.4.6.2_Linux_x86-64_rpm/RPMS/*.rpm

#It's not required but Xvfb if you experiences issue getting a shell
#back to your local system. Just ensure to uncomment the lines in the
#script though in my test I did not require it

cat << EOF > /home/madnar/.scripts/process_docs.sh
#!/bin/bash
#

#
#/usr/bin/Xvfb :10 &
#export DISPLAY=:10.0
DOCS_PATH=/srv/nfs/support
#use a for loop encase of multiple docs
case \$1 in
    1)
      for i in \$(/bin/ls /srv/nfs/support/*.odt); do
          /bin/libreoffice5.4 --headless \$DOCS_PATH/\$i
      done
      ;;
    2)
      /bin/pkill Xvfb
      /bin/pkill libreoffice5.4
      /bin/pkill oosplash
      /bin/pkill soffice
      /bin/rm /srv/nfs/support/*.odt
      ;;
esac
EOF

chmod +x /home/madnar/.scripts/process_docs.sh

cat << EOF > /etc/cron.d/process_doc
*/5 * * * * madnar /home/madnar/.scripts/process_docs.sh 1
*/7 * * * * root /home/madnar/.scripts/process_docs.sh 2
EOF

echo "[+] Install & configure DNSmasq on the system"
curl -L http://$APP_SERVER/dnsmasq-2.87.tar.gz -o /tmp/dnsmasq-2.87.tar.gz
tar xvf dnsmasq-2.87.tar.gz
cd dnsmasq-2.87
make install
chmod +s $(which dnsmasq)

echo "[+] Configure the resolve.conf & look back interface"
cat << EOF > /etc/resolv.conf
1.0.1.0:553
8.8.4.4

options timeout:1 attempts:3
EOF
nmcli connection add type dummy ifname fallback ipv4.method manual ipv4.addresses 1.0.1.0/24

echo "[+] Set system's auth_configurator"
curl -L http://$APP_SERVER/auth_configurator -o /sbin/auth_configurator
chmod +rxs /usr/sbin/auth_configurator ## Security weakness making files readable when they should not be

mkdir /root/.ssh

#This is there to help under the programs usage
cat << EOF > /etc/cron.d/auth_conf
30 5 * * * root /usr/sbin/auth_configurator /root/
EOF

echo "[+] Dropping flags"
echo "f06df28805c98b747719138b0d7db4ef" > /root/proof.txt
echo "556ea569c50d07a16695977c46079960" > /home/madnar/local.txt
chmod 0600 /root/proof.txt
chmod 0644 /home/madnar/local.txt
chown madnar:madnar /home/madnar/local.txt

echo "[+] Cleaning up"
rm -rf /root/build.sh
rm -rf /root/.cache
rm -rf /root/.viminfo
rm -rf /home/madnar/.sudo_as_admin_successful
rm -rf /home/madnar/.cache
rm -rf /home/madnar/.viminfo
rm -rf /tmp/*
cd /
find /var/log -type f -exec sh -c 'cat /dev/null > {}' \;
