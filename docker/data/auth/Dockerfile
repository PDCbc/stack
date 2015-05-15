# Dockerfile for the PDC's Auth service
#
# Base image
#
FROM phusion/passenger-nodejs


# Install DACS
#
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update; apt-get install -y dacs


# Prepare /app/ and /etc/dacs/federations/ folders
#
WORKDIR /app/
COPY ./app.sh /app/
RUN chown -R app:app /app/ /etc/dacs/federations/


# Create startup script and make it executable
#
RUN mkdir -p /etc/service/app/
RUN ( \
      echo "#!/bin/bash"; \
      echo ""; \
#      echo "cd /app"; \
#      echo "./app.sh"; \
      echo "exec /sbin/setuser app /app/app.sh"; \
    )  \
    >> /etc/service/app/run
RUN chmod +x /etc/service/app/run


# Run Command
#
CMD ["/sbin/my_init"]
