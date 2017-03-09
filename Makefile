default: ssl
	git clone $GIT_REPO /wiki/data
	gollum --port 8080 --host localhost --config /wiki/config.rb

prepare:
	export LC_ALL="en_US.UTF-8"
	export LC_CTYPE="en_US.UTF-8"
	. /etc/enviroment

ssl: prepare
    service nginx start
	certbot-auto -n certonly -a webroot --webroot-path=/wiki/webssl -d ${DOMAIN} --agree-tos --email ${SSL_EMAIL}
	openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
	rm /etc/nginx/sites-available/gollum.conf
	mv /wiki/tmp/gollum-ssl.conf /etc/nginx/sites-available/gollum.conf
	sed -ie "s/<placeholder>/${DOMAIN}/g" /etc/nginx/sites-available/gollum.conf
	service nginx restart