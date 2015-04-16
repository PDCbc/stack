# Dockerfile for the PDC's Hub service
#
# Base image
#
FROM phusion/passenger-ruby19


# ENV - Set non-interactive shell and disable policy-rc.d
#
ENV DEBIAN_FRONTEND noninteractive
RUN sed -i -e "s/exit 101/exit 0/" /usr/sbin/policy-rc.d


# Install applications from repos
#
RUN apt-get update; \
    apt-get --yes install ntp libxslt-dev libxml2-dev lynx


# ENV and User
#
USER app
ENV HOME /home/app/


# Install Hub Software
#
WORKDIR /home/app
RUN git clone https://github.com/physiciansdatacollaborative/hub.git; \
    git -C hub/ checkout -q pdc-0.1.0


WORKDIR /home/app/hub
COPY ./branding/assets-images/* /home/app/hub/app/assets/images/
COPY ./branding/views-devise-passwords/* /home/app/hub/app/views/devise/passwords/
COPY ./branding/views-devise-registrations/* /home/app/hub/app/views/devise/registrations/
COPY ./branding/views-devise-sessions/* /home/app/hub/app/views/devise/sessions/
COPY ./branding/views-shared/* /home/app/hub/app/views/shared/
COPY ./branding/views-layouts/* /home/app/hub/app/views/layouts/
RUN bundle install --path vendor/bundle; \
    mkdir -p /home/app/hub/tmp/pids; \
    sed -i -e "s/localhost:27017/database:27017/" config/mongoid.yml


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


# Copy hub startup script and make it executable
#
ADD scripts/hub.sh /etc/service/hub/run
RUN chmod +x /etc/service/hub/run


# Expose ports to incoming traffic
#
EXPOSE 3002


# Run Command
#
CMD ["/sbin/my_init"]
