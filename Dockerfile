FROM ubuntu:14.04
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
RUN apt-get -y install apache2 php5 php5-gd libapache2-mod-php5 postfix wget supervisor php5-pgsql vim curl libcurl3 libcurl3-dev php5-curl php5-xmlrpc php5-intl php5-mysql php5-zip

# SSH
RUN apt-get -y install openssh-server
RUN mkdir -p /var/run/sshd

# mysql config
RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

# PHP config
RUN sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 512M/g" /etc/php5/apache2/php.ini
RUN sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 512M/g" /etc/php5/apache2/php.ini
## Others to consider:
## 		max_execution_time = 300
## 		memory_limit = 128M
## 		extension_dir = "\xampp-7.0.15\php\ext"
## It may also be possible to override php configs with .htaccess file inside /var/www/html/moodle/

# PHP Extensions
#
# The following PHP extensions are required or recommended (some, e.g. iconv, ctype and
# tokenizer are now included in PHP by default). Others will need to be installed or selected.
#
# The mbstring extension is recommended.
# The openssl extension is recommended (required for networking and web services).
# The tokenizer extension is recommended.
# The soap extension is recommended (required for web services).
# The gd extension is recommended (required for manipulating images).
# The simplexml extension is required.  Before PHP 5.1.2, --enable-simplexml is required to enable this extension.
# The pcre extension is required. The PCRE extension is a core PHP extension, so it is always enabled
# The dom extension is required. This extension is enabled by default. It may be disabled by using the following option at compile time: --disable-dom
# The xml extension is required. This extension is enabled by default. It may be disabled by using the following option at compile time: --disable-xml
# The json extension is required. As of PHP 5.2.0, the JSON extension is bundled and compiled into PHP by default.

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

