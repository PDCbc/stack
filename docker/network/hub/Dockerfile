# Dockerfile for the PDC's Hub service
#
# Base image
#
FROM phusion/passenger-ruby19


# Update (non-interactive) and install packages
#
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update; apt-get install -y lynx


# Enable and configure SSH (for AutoSSH tunnel)
#
RUN rm -f /etc/service/sshd/down
#
RUN adduser --quiet --disabled-password autossh 2>&1
RUN /sbin/setuser autossh mkdir /home/autossh/.ssh
RUN /sbin/setuser autossh touch /home/autossh/.ssh/authorized_keys
RUN /sbin/setuser autossh chmod -R go-rwx /home/autossh/.ssh


# Copy and prepare startup script
#
COPY ./app.sh /app/
RUN chown -R app:app /app
#
RUN mkdir -p /etc/service/app
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
