#FROM fedora
#RUN yum update -y
#RUN yum install -y gcc git ruby ruby-devel gcc-c++ libicu-devel
#RUN gem install gollum omniauth omniauth-facebook omniauth-bitbucket omnigollum
#RUN curl ftp://ftp.ruby-lang.org/pub/ruby/ruby-2.3.3.tar.gz > /tmp/ruby-2.3.3.tar.gz
#RUN cd /tmp && tar -xzf ruby-2.3.3.tar.gz
FROM ruby
# Bootstrapping
RUN export LC_ALL="en_US.UTF-8"
RUN export LC_CTYPE="en_US.UTF-8"
ADD config.env ~/
RUN cat ~/config.env >> /etc/enviroment && source /etc/enviroment

#Installing system tools
RUN apt-get -y update && apt-get -y install libicu-dev nginx
RUN gem install gollum
RUN gem install github-markdown org-ruby omniauth omnigollum multi_json omniauth-bitbucket

# Prepare nginx for proxying
EXPOSE 443
EXPOSE 80
RUN rm /etc/nginx/sites-enabled/*
ADD gollum.conf /etc/nginx/sites-available
RUN ln -s /etc/nginx/sites-available/gollum.conf /etc/nginx/sites-enabled/gollum.conf
RUN service nginx start

# Installing letsencrypt
RUN mkdir -p /wiki/webssl
RUN apt-get install letsencrypt
RUN certbot-auto -n certonly -a webroot --webroot-path=/wiki/webssl -d ${DOMAIN} --agree-tos --email ${SSL_EMAIL}
RUN openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

# Adding ssl parameters
RUN rm /etc/nginx/sites-available/gollum.conf
ADD gollum-ssl.conf /etc/nginx/sites-available/gollum.conf
RUN sed -ie "s/<placeholder>/${DOMAIN}/g" /etc/nginx/sites-available/gollum.conf
RUN service nginx restart

# Cloning wiki repo
RUN mkdir ~/.ssh/
ADD id_rsa* ~/.ssh/
ADD known_hosts ~/.ssh/
RUN chmod go-rwx ~/.ssh/* && mkdir -p /wiki/data && git clone $GIT_REPO /wiki/data

# Setting
ADD config.rb /wiki/
#ENTRYPOINT ["gollum", "--port", "8080", "--host", "localhost", "--config", "/wiki/config.rb"]
ENTRYPOINT [ "bash" ]