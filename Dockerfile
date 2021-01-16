# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: mbaxmann <marvin@42.fr>                    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/01/06 14:18:19 by mbaxmann          #+#    #+#              #
#    Updated: 2020/01/20 15:33:27 by mbaxmann         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM debian:buster

RUN apt-get update
RUN apt-get upgrade -y

RUN apt-get -y install nginx

RUN apt-get -y install mariadb-server

RUN apt-get -y install php7.3 php-mysql php-fpm php-cli php-mbstring

RUN apt-get -y install wget

COPY ./srcs/start.sh /var/
COPY ./srcs/mysql_setup.sql /var/
COPY ./srcs/nginx.conf /etc/nginx/sites-available/localhost

RUN ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/

COPY srcs/wordpress-5.3.2.tar.gz /var/www/html
WORKDIR /var/www/html
RUN tar -xf wordpress-5.3.2.tar.gz
RUN rm wordpress-5.3.2.tar.gz

WORKDIR /var/www/html
RUN wget https://files.phpmyadmin.net/phpMyAdmin/4.9.1/phpMyAdmin-4.9.1-english.tar.gz
RUN tar -xf  phpMyAdmin-4.9.1-english.tar.gz
RUN rm phpMyAdmin-4.9.1-english.tar.gz
COPY ./srcs/config.inc.php /var/www//html/phpMyAdmin-4.9.1-english/
RUN mv phpMyAdmin-4.9.1-english phpmyadmin

RUN service mysql start && mysql -u root mysql < /var/mysql_setup.sql
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj '/C=FR/ST=75/L=Paris/O=42/CN=mbaxmann' -keyout /etc/ssl/certs/localhost.key -out /etc/ssl/certs/localhost.crt

RUN chown -R www-data:www-data /var/www/*
RUN chmod -R 755 /var/www/*

EXPOSE 80 443

CMD bash /var/start.sh
