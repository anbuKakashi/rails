FROM seapy/ruby:2.1.2
MAINTAINER ChangHoon Jeong <iamseapy@gmail.com>
MAINTAINER KakaFuad

RUN apt-get update

#Install editor nano
RUN apt-get install nano

# Install nodejs
RUN apt-get install -qq -y nodejs

# Intall software-properties-common for add-apt-repository
RUN apt-get install -qq -y software-properties-common

# Install Nginx.
RUN add-apt-repository -y ppa:nginx/stable
RUN apt-get update
RUN apt-get install -qq -y nginx
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf
RUN chown -R www-data:www-data /var/lib/nginx

# Add default nginx config
ADD nginx/default /etc/nginx/sites-enabled/default

# Install foreman
RUN gem install foreman

# Install the latest postgresql lib for pg gem
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --force-yes libpq-dev

## Install MySQL(for mysql, mysql2 gem)
RUN apt-get install -qq -y libmysqlclient-dev

COPY ../shared/config/secrets.yml /config/secrets.yml
#COPY . .

# Install Rails App
WORKDIR /app
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN bundle install
ADD . /app

RUN mkdir -p shared/pids shared/sockets shared/log

# Add default unicorn config
ADD config/unicorn.rb /app/config/unicorn.rb

# Add default foreman config
ADD Procfile /app/Procfile

#ENV RAILS_ENV production
ENV RAILS_ENV development

CMD bundle exec rake assets:precompile && foreman start -f Procfile
