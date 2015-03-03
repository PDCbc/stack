### A Dockerfile!
#
#


### Select the base image to use
#
FROM phusion/passenger-ruby19


### ENV - Set non-interactive shell and disable policy-rc.d
#
ENV DEBIAN_FRONTEND noninteractive
RUN sed -i -e "s/exit 101/exit 0/" /usr/sbin/policy-rc.d


### Install applications from repos
#
RUN apt-get update; \
    apt-get -y install libxslt-dev libxml2-dev lynx unzip


### Install multipart-post Gem
#
RUN /usr/bin/gem install multipart-post


### Switch to app (non-root) user and set home directory
#
USER app
ENV HOME /home/app/


### Clone endpoint software
#
WORKDIR /home/app
RUN git clone https://github.com/scoophealth/query-gateway.git endpoint


### Create directories needed by endpoint software
#
WORKDIR /home/app/endpoint
RUN mkdir -p /home/app/endpoint/tmp/pids; \
    mkdir -p /home/app/endpoint/util/files


### Copy import files
#
ADD import/* /home/app/endpoint/util/files/


### Run endpoint software
#
WORKDIR /home/app/endpoint
RUN bundle install --path vendor/bundle


# Configure mongo port (db at ‘database:27017’, instead of local install)
#
RUN sed -i -e "s/localhost:27017/database:27017/" config/mongoid.yml


### Change back to root
#
USER root


### Copy endpoint startup script and make it executable
#
ADD scripts/endpoint.sh /etc/service/endpoint/run
RUN chmod +x /etc/service/endpoint/run


### Expose ports to incoming traffic
#
EXPOSE 3001 3000


### Run initialization command
#
CMD ["/sbin/my_init"]
