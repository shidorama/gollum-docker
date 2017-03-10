# About
 This is complete All-In-One package for setting-up gollum on dedicated server with nginx as reverse proxy and letsencrypt as automatic ssl solution
 
# Preparation
 1. Get dedicated A name on your dns and assign it to servers IP
 1. Open ports 80 and 443 on a servers firewall and check them 
 
# Installation

1. generate ssh keys
1. add gnerated ssh key to wiki bitbucket repository
1. copy key to project directory; They should be named id_rsa and id_rsa.pub respectively for private and public key
1. add oauth to bitbucket account and give it read permissions on everything
1. set config options in config.env
1. build docker image (``Docker build -t gollum-wiki:latest .``)
1. run docker, publish ports 80 and 443 (``Docker run -p 80:80 -p 443:443 gollum-wiki:latest``)

