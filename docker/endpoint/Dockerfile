# Dockerfile for the PDC's Endpoint service
#
# Base image
#
FROM phusion/passenger-ruby19


# ENV - Set non-interactive shell and disable policy-rc.d
#
ENV DEBIAN_FRONTEND noninteractive
RUN sed -i -e "s/exit 101/exit 0/" /usr/sbin/policy-rc.d


# Expose ports listening for incoming traffic
#
EXPOSE 3001 3000


# Install applications from repos
#
RUN apt-get update; \
    apt-get install -y libxslt-dev \
                       libxml2-dev \
                       lynx \
                       unzip


# Install multipart-post Gem
#
RUN /usr/bin/gem install multipart-post


# Switch to app (non-root) user and set home directory
#
USER app
ENV HOME /home/app/


# Clone endpoint software
#
WORKDIR /home/app
RUN git clone https://github.com/physiciansdatacollaborative/endpoint.git; \
    git -C endpoint checkout -q pdc-0.1.0


# Create directories needed by endpoint software
#
WORKDIR /home/app/endpoint
RUN mkdir -p /home/app/endpoint/tmp/pids; \
    mkdir -p /home/app/endpoint/util/files


# Copy import files
#
ADD import/* /home/app/endpoint/util/files/


# Run endpoint software
#
WORKDIR /home/app/endpoint
RUN bundle install --path vendor/bundle


# Configure mongo port (db at ‘database:27017’, instead of local install)
#
RUN sed -i -e "s/localhost:27017/database:27017/" config/mongoid.yml


# Change back to root
#
USER root


# Start in /home/app/endpoint
#
RUN echo "" >> /root/.bashrc
RUN echo "# Start in /home/app/endpoint" >> /root/.bashrc
RUN echo "#" >> /root/.bashrc
RUN echo "cd /home/app/endpoint" >> /root/.bashrc


# Copy endpoint startup script and make it executable
#
ADD scripts/endpoint.sh /etc/service/endpoint/run
RUN chmod +x /etc/service/endpoint/run


# Run initialization command
#
CMD ["/sbin/my_init"]
