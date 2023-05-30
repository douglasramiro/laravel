#!/bin/bash
# Author Douglas Silva | douglas.silva@4pcapital.com.br


export WEB_DIR="/var/www/html"
export WEB_USER="ec2-user"

cd $WEB_DIR

# change user owner to apach
sudo chown -R apache:apache .

# install composer deps
sudo -u $WEB_USER composer install --no-dev --no-progress --prefer-dist

# generate app key
sudo -u $WEB_USER php artisan key:generate
