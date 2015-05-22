# Dockerfile for the PDC's Auth service
#
# Base image
#
FROM phusion/passenger-nodejs


# Update system, install DACS
#
ENV DEBIAN_FRONTEND noninteractive
RUN echo 'Dpkg::Options{ "--force-confdef"; "--force-confold" }' \
      >> /etc/apt/apt.conf.d/local
RUN apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y dacs


# Prepare /app/ and /etc/dacs/federations/ folders
#
WORKDIR /app/
RUN git clone https://github.com/physiciansdatacollaborative/auth.git .
RUN npm install
RUN mkdir -p /etc/dacs/
COPY ./app.sh /app/
RUN chown -R app:app /app/


# Create startup script and make it executable
#
RUN mkdir -p /etc/service/app/
RUN ( \
      echo "#!/bin/bash"; \
      echo ""; \
      echo "chown -R app:app /etc/dacs/"; \
      echo "/sbin/setuser app /app/app.sh"; \
    )  \
    >> /etc/service/app/run
RUN chmod +x /etc/service/app/run


# Run Command
#
CMD ["/sbin/my_init"]
