#!/bin/bash
#
# Setup an Ubuntu VM with the OpenStack Cloud Tools

apt-get update -y
apt-get install python-pip python-dev -y
apt-get install libffi-dev libssl-dev build-essential -y

pip install -U pyopenssl ndg-httpsclient pyasn1 urllib3[secure]

clients='openstack
nova
neutron
glance
heat
cinder
swift
monasca
designate
keystone'

for n in ${clients}
do
  pip install -U python-${n}client
done

easy_install --upgrade requests[security]


echo "`ip addr show eth0 | awk '/ inet / {print $2}' | cut -d\/ -f1`  `hostname`" >> /etc/hosts

user=`ls /home | head -1`
cat > /home/$user/openrc.sh <<EOF
#!/bin/bash
export OS_AUTH_URL=https://dnvrco-api.os.cloud.twc.net:5000/v2.0
export OS_TENANT_NAME=rstarmer-class
echo "Your Tenant Name is: \${OS_TENANT_NAME}"
export OS_PROJECT_NAME=rstarmer-class

# In addition to the owning entity (tenant), OpenStack stores the entity
# performing the action as the **user**.
echo "Please enter your TimeWarner EID (e.g. EXXXXXX): "
read -r OS_USER_INPUT
export OS_USERNAME=\$OS_USER_INPUT
echo "You set your EID to: \${OS_USERNAME}"

# With Keystone you pass the keystone password.
echo "Please enter your TimeWarner EID Password (yes _YOUR_ password, not a random one): "
read -sr OS_PASSWORD_INPUT
export OS_PASSWORD=\$OS_PASSWORD_INPUT

# If your configuration has multiple regions, we set that information here.
# OS_REGION_NAME is optional and only valid in certain environments.
export OS_REGION_NAME="NCW"
echo "Your region is set to \${OS_REGION_NAME}"
export PS1='[\u@\h \W(nce)]\$ '
EOF

chown $user.$user /home/$user/*.sh
