default: clone
	gollum --port 8080 --host localhost --config /wiki/config.rb --base-path /wiki /wiki/data

clone: ssl updater
	git clone ${GIT_REPO} /wiki/data
	git config --global push.default matching
	touch clone

updater:
	/usr/bin/crontab crontab
	touch updater

ssl:
	service nginx start
	certbot-auto -n certonly -a webroot --webroot-path=/wiki/webssl -d ${DOMAIN} --agree-tos --email ${SSL_EMAIL}
	openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
	rm /etc/nginx/sites-available/gollum.conf
	mv /wiki/tmp/gollum-ssl.conf /etc/nginx/sites-available/gollum.conf
	sed -ie "s/<placeholder>/${DOMAIN}/g" /etc/nginx/sites-available/gollum.conf
	service nginx restart
	touch ssl

clean:
	rm ssl clone updater