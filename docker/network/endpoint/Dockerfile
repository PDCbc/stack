# Dockerfile for the PDC's Endpoint service
#
# Base image
#
FROM phusion/passenger-ruby19


# Branch to use from GitHub
#
ENV BRANCH pdc-0.1.0


# Update (non-interactive) and install packages
#
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update; apt-get install -y lynx unzip


# Install Endpoint software
#
WORKDIR /app
RUN git clone https://github.com/physiciansdatacollaborative/endpoint.git
RUN git -C endpoint checkout -q $BRANCH
RUN chown -R app:app /app


# Install multipart-post Gem
#
RUN /usr/bin/gem install multipart-post


# Configure Endpoint (run bundler as non-root)
#
RUN /sbin/setuser app bundle install --path vendor/bundle
RUN mkdir -p /app/endpoint/tmp/pids; \
    mkdir -p /app/endpoint/util/files
RUN sed -i -e "s/localhost:27017/epdb:27017/" config/mongoid.yml


# Create Endpoint startup script and make it executable
#
RUN mkdir -p /etc/service/endpoint
RUN ( \
      echo "#!/bin/bash"; \
      echo ""; \
      echo "cd /app"; \
      echo "exec /sbin/setuser app './runme.sh'"; \
    )  \
    >> /etc/service/endpoint/run
RUN chmod +x /etc/service/endpoint/run


# Run initialization command
#
CMD ["/sbin/my_init"]
