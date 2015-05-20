# Dockerfile for the PDC's Endpoint service
#
# Base image
#
FROM phusion/passenger-ruby19


# Branch to use from GitHub
#
ENV BRANCH pdc-0.1.0


# Update (non-interactive) and install packages
#
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update; apt-get install -y \
      autossh \
      lynx \
      unzip


# Clone repo, assign to app
#
WORKDIR /app/
RUN git clone -b ${BRANCH} https://github.com/physiciansdatacollaborative/endpoint.git .
RUN mkdir -p /app/tmp/pids /app/util/files
RUN chown -R app:app /app/


# Configure Endpoint (run bundler as non-root)
#
RUN /usr/bin/gem install multipart-post
RUN /sbin/setuser app bundle install --path vendor/bundle
RUN sed -i -e "s/localhost:27017/epdb:27017/" config/mongoid.yml


# Create startup script and make it executable
#
RUN mkdir -p /etc/service/app
RUN ( \
      echo "#!/bin/bash"; \
      echo ""; \
      echo "apt-get update; apt-get upgrade -y"; \
      echo ""; \
      echo "# Wait until SSH keys are ready"; \
      echo "#"; \
      echo "while [ -f /app/wait ]"; \
      echo "do"; \
      echo "  echo 'Waiting for key exchange'"; \
      echo "  sleep 10"; \
      echo "done"; \
      echo ""; \
      echo "# Start tunnel"; \
      echo "#"; \
      echo "cd /app/"; \
      echo "export AUTOSSH_PIDFILE=/app/tmp/pids/autossh.pid"; \
      echo "export REMOTE_PORT=\`expr 40000 + \${gID}\`"; \
      echo "/usr/bin/autossh -M0 -p2774 -N -R \${REMOTE_PORT}:localhost:3001 autossh@\${HUB_URL} -o ServerAliveInterval=15 -o ServerAliveCountMax=3 -o Protocol=2 -o ExitOnForwardFailure=yes &"; \
      echo "sleep 5"; \
      echo ""; \
      echo "# Start Endpoint"; \
      echo "#"; \
      echo "exec /sbin/setuser app '/app/runme.sh'"; \
    )  \
    >> /etc/service/app/run
RUN chmod +x /etc/service/app/run


# Create key exchange script, uses a wait file (/app/wait)
#
RUN ( \
      echo "#!/bin/bash"; \
      echo "#"; \
      echo "# Exit on errors or unitialized variables"; \
      echo "#"; \
      echo "set -e -o nounset"; \
      echo ""; \
      echo "# Create an SSH key and exchange it"; \
      echo "#"; \
      echo "ssh-keygen -t rsa -f /root/.ssh/id_rsa -q -N \"\""; \
      echo "scp -P 2774 -p /root/.ssh/id_rsa.pub pdcadmin@\${HUB_URL}:/tmp/endpoint_id_rsa.pub"; \
      echo "ssh -p 2774 -t pdcadmin@\${HUB_URL} \"sudo su - autossh -c 'cat /tmp/endpoint_id_rsa.pub >> /home/autossh/.ssh/authorized_keys'\""; \
      echo ""; \
      echo "# Remove the hold on Endpoint startup"; \
      echo "#"; \
      echo "rm /app/wait"; \
    )  \
    >> /app/key_exchange.sh
RUN chmod +x /app/key_exchange.sh
RUN touch /app/wait


# Run initialization command
#
CMD ["/sbin/my_init"]
