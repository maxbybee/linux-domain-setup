
# SETUP NETWORK
echo "" >> /etc/network/interfaces;
echo "auto ens19" >> /etc/network/interfaces;
echo "iface ens19 inet static" >> /etc/network/interfaces;
echo "	address 10.0.0.1" >> /etc/network/interfaces;
echo "	netmask 255.255.255.0" >> /etc/network/interfaces;
echo "	gateway 10.0.0.254" >> /etc/network/interfaces;
echo '
alias {   interface "ens19";   
fixed-address 10.0.0.1;   
option subnet-mask 255.255.255.0; }' >> /etc/dhcp/dhclient.conf
ifdown -a;
dhclient -i ens18;
ifup lo;
ifup ens19;
echo "======================="
echo ""
echo DOMAIN TO CONFIGURE $SUBD.$MAIND
echo ""
echo "======================="
# SETUP RESOLV CONF
echo "10.0.0.1 $SUBD.$MAIND $SUBD" > /etc/hosts
systemctl disable --now systemd-resolved;
unlink /etc/resolv.conf;
touch /etc/resolv.conf;
echo "nameserver 10.0.0.1" >> /etc/resolv.conf;
echo "nameserver 8.8.8.8" >> /etc/resolv.conf;
echo "search $MAIND" >> /etc/resolv.conf;
chattr +i /etc/resolv.conf;

# SETUP SOFTWARE
apt install -y acl attr samba samba-dsdb-modules samba-vfs-modules smbclient winbind libpam-winbind libnss-winbind libpam-krb5 krb5-config krb5-user dnsutils chrony net-tools;
systemctl disable --now smbd nmbd winbind
systemctl unmask samba-ad-dc
systemctl enable samba-ad-dc
mv /etc/samba/smb.conf /etc/samba/smb.conf.orig
samba-tool domain provision

# defaults
# dns forwarder 8.8.8.8


mv /etc/krb5.conf /etc/krb5.conf.orig
cp /var/lib/samba/private/krb5.conf /etc/krb5.conf
systemctl start samba-ad-dc

# SETUP NTP
chown root:_chrony /var/lib/samba/ntp_signd/
chmod 750 /var/lib/samba/ntp_signd/
echo "bindcmdaddress 10.0.0.1" >> /etc/chrony/chrony.conf;
echo "allow 10.0.0.0/24" >> /etc/chrony/chrony.conf;
echo "ntpsigndsocket /var/lib/samba/ntp_signd" >> /etc/chrony/chrony.conf;
systemctl restart chronyd

# CHECK IF WORKING
echo "==========="
echo "YOU SHOULD SEE 4 VALID RESPONSES HERE:"
echo "IF NOT, SOMETHING WENT WRONG."
echo "==========="
host -t A $MAIND
host -t A $SUBD.$MAIND
host -t SRV _kerberos._udp.$MAIND
host -t SRV _ldap._tcp.$MAIND
smbclient -L $MAIND -N

# TEST LOGIN
echo 'LOGIN BELOW, YOU SHOULD SEE SOMETHING SIMILAR TO "Warning: Your password will expire in 41 days" ON SUCCESSFUL LOGIN'
kinit administrator
klist

# CREATE A USER
# samba-tool user create alice alice_password88

# LIST USERS
samba-tool user list

