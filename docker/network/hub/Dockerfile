# Dockerfile for the PDC's Hub service
#
# Base image
#
FROM phusion/passenger-ruby19


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


# Update system, install Lynx
#
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y lynx


# Enable and configure SSH (for AutoSSH tunnel)
#
RUN rm -f /etc/service/sshd/down
#
RUN adduser --quiet --disabled-password autossh 2>&1
RUN /sbin/setuser autossh mkdir -p /home/autossh/.ssh
RUN /sbin/setuser autossh touch /home/autossh/.ssh/authorized_keys
RUN /sbin/setuser autossh chmod -R go-rwx /home/autossh/.ssh


# Prepare /app/ folder
#
WORKDIR /app/
COPY ./app.sh /app/
RUN chown -R app:app /app/


# Create startup script and make it executable
#
RUN mkdir -p /etc/service/app
RUN ( \
      echo "#!/bin/bash"; \
      echo ""; \
      echo "apt-get update; apt-get upgrade -y"; \
      echo ""; \
      echo "exec /sbin/setuser app /app/app.sh"; \
    )  \
    >> /etc/service/app/run
RUN chmod +x /etc/service/app/run


# Run Command
#
CMD ["/sbin/my_init"]
