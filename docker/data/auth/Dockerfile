# Dockerfile for the PDC's Auth service
#
# Base image
#
FROM phusion/passenger-nodejs


# Apt (w/ dpkg) - keep old files on conflicts
#
RUN mkdir -p /etc/apt/apt.conf.d/
RUN ( \
      echo 'Dpkg::Options {'; \
      echo '   "--force-confdef";'; \
      echo '   "--force-confold";'; \
      echo '}'; \
    )  \
    >> /etc/apt/apt.conf.d/local


# Update system, install DACS
#
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y dacs


# Prepare /app/ and /etc/dacs/federations/ folders
#
WORKDIR /app/
COPY ./app.sh /app/
RUN mkdir -p /etc/dacs/
RUN chown -R app:app /app/ /etc/dacs/


# Create startup script and make it executable
#
RUN mkdir -p /etc/service/app/
RUN ( \
      echo "#!/bin/bash"; \
      echo "#"; \
      echo "chown -R app:app /etc/dacs/"; \
      echo "/sbin/setuser app /app/app.sh"; \
    )  \
    >> /etc/service/app/run
RUN chmod +x /etc/service/app/run


# Run Command
#
CMD ["/sbin/my_init"]
