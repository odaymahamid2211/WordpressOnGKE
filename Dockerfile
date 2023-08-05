FROM ubuntu

# Install Apache, PHP, and WordPress
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq apt-utils htop apache2 apache2-utils php libapache2-mod-php php-mysql php-apcu wget ufw && \
  
    ufw allow 'Apache Full' && \
    rm /var/www/html/index.* && \
    cd /tmp && wget -c http://wordpress.org/latest.tar.gz && \
    tar xzvf latest.tar.gz --strip-components=1 -C /var/www/html/ && \
    chown -R www-data:www-data /var/www/html/ && \
    chmod -R 755 /var/www/html/ && \
    cd /var/www/html/ && \
    sed -i "s/80/80/g" /etc/apache2/sites-available/000-default.conf && \
    # Increase the size limit of the request headers
    echo "LimitRequestFieldSize 16384" >> /etc/apache2/apache2.conf && \

    rm /tmp/latest.tar.gz && \
    apt-get clean

# Restart Apache
RUN service apache2 restart

# Expose port 80
EXPOSE 80

# Start Apache in the foreground
CMD ["apache2ctl", "-D", "FOREGROUND"]
