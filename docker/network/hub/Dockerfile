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


# Clone repo, assign to app
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


# Expose ports
#
EXPOSE 3002
EXPOSE 22


# Enable SSH
#
RUN rm -f /etc/service/sshd/down


# Regenerate SSH host keys. baseimage-docker does not contain any, so you
# have to do that yourself. You may also comment out this instruction; the
# init system will auto-generate one during boot.
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh


# AutoSSH
#
RUN adduser --quiet --disabled-password autossh
RUN mkdir /home/autossh/.ssh
RUN touch /home/autossh/.ssh/authorized_keys
RUN chmod -R go-rwx /home/autossh/.ssh
RUN chown -R autossh:autossh /home/autossh/.ssh


# Run Command
#
CMD ["/sbin/my_init"]
