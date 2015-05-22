# Dockerfile for the PDC's DCLAPI service
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


# Update system
#
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update; \
    apt-get upgrade -y


# Prepare /app/ folder
#
WORKDIR /app/
COPY ./dcl.sqlite /app/
COPY ./app.sh /app/
RUN chown -R app:app /app/


# Create startup script and make it executable
#
RUN mkdir -p /etc/service/app/
RUN ( \
      echo "#!/bin/bash"; \
      echo ""; \
      echo "exec /sbin/setuser app /app/app.sh"; \
    )  \
    >> /etc/service/app/run
RUN chmod +x /etc/service/app/run


# Run Command
#
CMD ["/sbin/my_init"]
