#!/bin/sh

sudo rsync -av * /var/lib/sifau/
sudo chown -R www-data /var/lib/sifau
sudo apache2ctl restart
