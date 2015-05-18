# Dockerfile for the PDC's queryImporter service
#
# Base image
#
FROM phusion/passenger-nodejs


# Install NodeJs (0.12.x) and Python 2.7
#
RUN curl -sL https://deb.nodesource.com/setup_0.12 | sudo bash -
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update; apt-get install -y nodejs python2.7


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
      echo ""; \
      echo "# Update system"; \
      echo "#"; \
      echo "DEBIAN_FRONTEND=noninteractive"; \
      echo "apt-get update; apt-get dist-upgrade -y"; \
      echo ""; \
      echo "/sbin/setuser app /app/app.sh"; \
    )  \
    >> /etc/service/app/run
RUN chmod +x /etc/service/app/run


# Run Command
#
CMD ["/sbin/my_init"]
