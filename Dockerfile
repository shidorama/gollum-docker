FROM ruby

EXPOSE 443
EXPOSE 80

RUN mkdir -p /wiki/tmp && mkdir -p /wiki/webssl && mkdir /root/.ssh/ && mkdir -p /wiki/data/

#Installing system tools
RUN apt-get -y update && apt-get -y install libicu-dev nginx cron
RUN gem install gollum
RUN gem install github-markdown org-ruby omniauth omnigollum multi_json omniauth-bitbucket

# Prepare nginx for proxying
RUN rm /etc/nginx/sites-enabled/* && ln -s /etc/nginx/sites-available/gollum.conf /etc/nginx/sites-enabled/gollum.conf

# Installing letsencrypt
RUN cd /usr/local/sbin && wget https://dl.eff.org/certbot-auto && chmod a+x /usr/local/sbin/certbot-auto
RUN /usr/local/sbin/certbot-auto -n --os-packages-only
RUN chmod -R go-rwx /root/.ssh/

# Bootstrapping

COPY [ "config.env", "gollum-ssl.conf", "check.sh", "crontab", "Makefile", "start.sh", "/wiki/tmp/" ]
COPY id_rsa* /root/.ssh/
COPY known_hosts /root/.ssh/
COPY gollum.conf /etc/nginx/sites-available/
ADD config.rb /wiki/
RUN chmod gou+x /wiki/tmp/start.sh
RUN chmod gou+x /wiki/tmp/check.sh && /wiki/tmp/check.sh
RUN cat /wiki/tmp/config.env >> /etc/environment



# Setting
ENTRYPOINT [ "/wiki/tmp/start.sh" ]