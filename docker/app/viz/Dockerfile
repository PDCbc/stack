# Dockerfile for the PDC's Visualizer service
#
# Base image
#
FROM phusion/passenger-nodejs


# Install Python 2.7
#
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update; apt-get install -y python2.7


# Prepare /app/ folder
#
WORKDIR /app/
COPY ./app.sh /app/
RUN chown -R app:app /app/


# Create startup script and make it executable
#
RUN mkdir -p /etc/service/app/
RUN ( \
      echo "#!/bin/bash"; \
      echo "#"; \
      echo "exec /sbin/setuser app /app/app.sh"; \
    )  \
    >> /etc/service/app/run
RUN chmod +x /etc/service/app/run


# Run Command
#
CMD ["/sbin/my_init"]
