#!/bin/bash
# Author Douglas Silva | douglas.silva@4pcapital.com.br


export WEB_DIR="/var/www/html"
export WEB_USER="apache"

cd $WEB_DIR

rm -rf /tmp/cicd.log

#creating .env file
sudo cp /var/www/html/.env.example /var/www/html/.env

if [ "$DEPLOYMENT_GROUP_NAME" == "laravel-codedeploy-group-s" ]
then
  DB_USERNAME=$(aws ssm get-parameter --name /database/prd/username --with-decryption --query Parameter.Value --region us-east-1)
else
  DB_USERNAME=$(aws ssm get-parameter --name /database/stage/username --with-decryption --query Parameter.Value --region us-east-1)
fi

sudo sed -i "s/##DB_USERNAME##/$DB_USERNAME/g" /var/www/html/.env

# change user owner to apach
sudo chown -R apache:apache .

# install composer deps
sudo -u $WEB_USER composer install --no-dev --no-progress --prefer-dist >> /tmp/cicd.log


# generate app key
sudo -u $WEB_USER php artisan key:generate >> /tmp/cicd.log


# creating virtual host

cat <<EOF > /etc/httpd/conf.d/laravel.conf
<VirtualHost *:80>
       ServerName laravel.example.com
       DocumentRoot /var/www/html/public
<Directory /var/www/html>
              AllowOverride All
       </Directory>
</VirtualHost>
EOF

sudo systemctl restart httpd
