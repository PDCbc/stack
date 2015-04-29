# Dockerfile for the PDC's Hub service
#
# Base image
#
FROM phusion/passenger-ruby19


# Branch to use from GitHub
#
ENV BRANCH dev


# Update (non-interactive) and install packages
#
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update; apt-get install -y lynx


# Install Hub software
#
WORKDIR /app
RUN git clone https://github.com/physiciansdatacollaborative/hub.git .
RUN git checkout $BRANCH
RUN chown -R app:app /app


# Configure Hub (run bundler as non-root)
#
RUN /sbin/setuser app bundle install --path vendor/bundle
RUN mkdir -p /home/app/hub/tmp/pids
RUN sed -i -e "s/localhost:27017/hubdb:27017/" config/mongoid.yml


# Create Hub startup script and make it executable
#
RUN mkdir -p /etc/service/hub
RUN ( \
      echo "#!/bin/bash"; \
      echo ""; \
      echo "cd /app"; \
      echo "exec /sbin/setuser app './runme.sh'"; \
    )  \
    >> /etc/service/hub/run
RUN chmod +x /etc/service/hub/run


# Run Command
#
CMD ["/sbin/my_init"]
