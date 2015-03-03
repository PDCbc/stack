# A Dockerfile!
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
RUN apt-get update && \
    apt-get --yes install ntp libxslt-dev libxml2-dev autossh lynx nmap


### ENV and User
#
USER app
ENV HOME /home/app/


### Install Hub Software
#
WORKDIR /home/app
RUN git clone https://github.com/scoophealth/query-composer hub
WORKDIR /home/app/hub
RUN bundle install --path vendor/bundle && \
    mkdir -p /home/app/hub/tmp/pids && \
    sed -i -e "s/localhost:27017/database:27017/" config/mongoid.yml


### Change back to root
#
USER root


### Copy hub startup script and make it executable
#
ADD scripts/hub.sh /etc/service/hub/run
RUN chmod +x /etc/service/hub/run


### Expose Port
#
EXPOSE 3002


### Run Command
#
CMD ["/sbin/my_init"]
