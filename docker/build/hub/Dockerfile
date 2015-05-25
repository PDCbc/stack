# Dockerfile for the PDC's Hub service
#
# Base image
#
FROM phusion/passenger-ruby19


# Update system, install Lynx
#
ENV DEBIAN_FRONTEND noninteractive
RUN echo 'Dpkg::Options{ "--force-confdef"; "--force-confold" }' \
      >> /etc/apt/apt.conf.d/local
RUN apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y lynx


# Prepare /app/ folder
#
WORKDIR /app/
RUN git clone https://github.com/physiciansdatacollaborative/hub.git .
COPY ./app.sh /app/
RUN chown -R app:app /app/


# Enable and configure SSH (for AutoSSH user/tunnel)
#
RUN rm -f /etc/service/sshd/down
RUN adduser --quiet --disabled-password --home /home/autossh autossh 2>&1


# Create startup script and make it executable
#
RUN mkdir -p /etc/service/app
RUN ( \
      echo "#!/bin/bash"; \
      echo ""; \
      echo "mkdir -p /home/autossh/.ssh/"; \
      echo "touch /home/autossh/.ssh/authorized_keys"; \
      echo "chown -R autossh:autossh /home/autossh/.ssh/"; \
      echo "exec /sbin/setuser app /app/app.sh"; \
    )  \
    >> /etc/service/app/run
RUN chmod +x /etc/service/app/run


# Run Command
#
CMD ["/sbin/my_init"]
