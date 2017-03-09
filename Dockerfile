FROM ruby

EXPOSE 443
EXPOSE 80

# Bootstrapping
ADD config.env /tmp
RUN cat /tmp/config.env >> /etc/environment

#Installing system tools
RUN apt-get -y update && apt-get -y install libicu-dev nginx
RUN gem install gollum
RUN gem install github-markdown org-ruby omniauth omnigollum multi_json omniauth-bitbucket

# Prepare nginx for proxying
RUN rm /etc/nginx/sites-enabled/*
ADD gollum.conf /etc/nginx/sites-available
RUN ln -s /etc/nginx/sites-available/gollum.conf /etc/nginx/sites-enabled/gollum.conf

# Installing letsencrypt
RUN mkdir -p /wiki/webssl
RUN mkdir -p /wiki/tmp
RUN cd /usr/local/sbin && wget https://dl.eff.org/certbot-auto && chmod a+x /usr/local/sbin/certbot-auto

# Adding ssl parameters
ADD gollum-ssl.conf /wiki/tmp/

# Cloning wiki repo
RUN mkdir /root/.ssh/
ADD id_rsa* /root/.ssh/
ADD known_hosts /root/.ssh/
RUN chmod go-rwx /root/.ssh/ && mkdir -p /wiki/data/

# Setting
ADD config.rb /wiki/
ADD Makefile /wiki/tmp/
ADD start.sh /wiki/tmp/
RUN chmod gou+x /wiki/tmp/start.sh

ENTRYPOINT [ "/wiki/tmp/start.sh" ]