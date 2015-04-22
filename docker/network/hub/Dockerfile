# Dockerfile for the PDC's Hub service
#
# Base image
#
FROM phusion/passenger-ruby19


# Set non-interactive shell and disable policy-rc.d
#
ENV DEBIAN_FRONTEND noninteractive
RUN sed -i -e "s/exit 101/exit 0/" /usr/sbin/policy-rc.d


# Install applications from repos
#
RUN apt-get update; \
    apt-get install -y libxslt-dev libxml2-dev lynx


# ENV and User
#
USER app
ENV HOME /home/app/


# Install Hub Software
#
WORKDIR /home/app
RUN git clone https://github.com/physiciansdatacollaborative/hub.git; \
    git -C hub/ checkout dev


WORKDIR /home/app/hub
RUN bundle install --path vendor/bundle
RUN mkdir -p /home/app/hub/tmp/pids
RUN sed -i -e "s/localhost:27017/hubdb:27017/" config/mongoid.yml


# Change back to root
#
USER root


# Start in /home/app/hub
#
RUN echo "" >> /root/.bashrc
RUN echo "# Start in /home/app/hub" >> /root/.bashrc
RUN echo "#" >> /root/.bashrc
RUN echo "cd /home/app/hub" >> /root/.bashrc
RUN echo ""
RUN echo "Add to PATH"
RUN echo "export PATH=$PATH:/usr/local/bin"


# Create hub startup script and make it executable
#
RUN mkdir -p /etc/service/hub
RUN echo "#!/bin/bash" >> /etc/service/hub/run
RUN echo "#" >> /etc/service/hub/run
RUN echo "# Halt on errors" >> /etc/service/hub/run
RUN echo "set -e -x -o nounset" >> /etc/service/hub/run
RUN echo "" >> /etc/service/hub/run
RUN echo "# Run hub as app user" >> /etc/service/hub/run
RUN echo "#" >> /etc/service/hub/run
RUN echo "chpst -u app bash -c 'export PATH=$PATH:/usr/local/bin; cd /home/app/hub/; ./runme.sh'" >> /etc/service/hub/run
RUN chmod +x /etc/service/hub/run


# Expose ports to incoming traffic
#
EXPOSE 3002


# Run Command
#
CMD ["/sbin/my_init"]
