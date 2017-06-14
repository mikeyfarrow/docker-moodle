FROM ubuntu:16.10
MAINTAINER Sergio Gómez <sergio@quaip.com>

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get -y upgrade
 
# Basic Requirements
RUN apt-get -y install mysql-server mysql-client pwgen python-setuptools curl git unzip

# Moodle Requirements
RUN apt-get -y install apache2 postfix wget supervisor vim curl libcurl3 libcurl3-dev
RUN apt-get -y install php php-mysql php-xml php-curl php-zip php-gd php-xmlrpc php-soap php-mbstring php-intl

# SSH
RUN apt-get -y install openssh-server
RUN mkdir -p /var/run/sshd

# apache required dirs
RUN mkdir -p /var/run/apache2
RUN mkdir -p /var/lock/apache2

# mysql required dirs
RUN mkdir -p /var/run/mysqld
RUN chown mysql /var/run/mysqld

# mysql config
RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

RUN easy_install supervisor
ADD ./start.sh /start.sh
ADD ./foreground.sh /etc/apache2/foreground.sh
ADD ./supervisord.conf /etc/supervisord.conf

ADD https://download.moodle.org/moodle/moodle-latest.tgz /var/www/moodle-latest.tgz
RUN cd /var/www; tar zxvf moodle-latest.tgz; mv /var/www/moodle /var/www/html
RUN chown -R www-data:www-data /var/www/html/moodle
RUN mkdir /var/moodledata
RUN chown -R www-data:www-data /var/moodledata; chmod 777 /var/moodledata
RUN chmod 755 /start.sh /etc/apache2/foreground.sh

EXPOSE 22 80
CMD ["/bin/bash", "/start.sh"]

