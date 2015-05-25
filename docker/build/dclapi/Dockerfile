# Dockerfile for the PDC's DCLAPI service
#
# Base image
#
FROM phusion/passenger-nodejs


# Update system
#
ENV DEBIAN_FRONTEND noninteractive
RUN echo 'Dpkg::Options{ "--force-confdef"; "--force-confold" }' \
      >> /etc/apt/apt.conf.d/local
RUN apt-get update; \
    apt-get upgrade -y


# Prepare /app/ folder
#
WORKDIR /app/
RUN git clone https://github.com/physiciansdatacollaborative/dclapi.git .
RUN npm install
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
