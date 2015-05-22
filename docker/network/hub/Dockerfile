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
#RUN bundle install --path vendor/bundle
#RUN sed -i -e "s/localhost:27017/hubdb:27017/" config/mongoid.yml
COPY ./app.sh /app/
RUN chown -R app:app /app/


# Enable and configure SSH (for AutoSSH tunnel)
#
RUN rm -f /etc/service/sshd/down
#
RUN adduser --quiet --disabled-password autossh 2>&1
RUN mkdir -p /home/autossh/.ssh
RUN touch /home/autossh/.ssh/authorized_keys
RUN chown -R autossh:autossh /home/autossh/.ssh/
RUN /sbin/setuser autossh chmod -R go-rwx /home/autossh/.ssh


# Create startup script and make it executable
#
RUN mkdir -p /etc/service/app
RUN ( \
      echo "#!/bin/bash"; \
      echo ""; \
      echo "chown -R autossh:autossh /home/autossh/.ssh/"; \
      echo "exec /sbin/setuser app /app/app.sh"; \
    )  \
    >> /etc/service/app/run
RUN chmod +x /etc/service/app/run


# Run Command
#
CMD ["/sbin/my_init"]
