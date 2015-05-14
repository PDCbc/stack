# Dockerfile for the PDC's Auth service
#
# Base image
#
FROM phusion/passenger-nodejs


# Update (non-interactive) and install packages
#
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update; apt-get install -y dacs


# Copy startup script and prep folders
#
WORKDIR /app/
COPY ./app.sh /app/
RUN chown app:app /app/


# Create startup script and make it executable
#
RUN mkdir -p /etc/service/app/
RUN ( \
      echo "#!/bin/bash"; \
      echo ""; \
      echo "cd /app"; \
      echo "./app.sh"; \
    )  \
    >> /etc/service/app/run
RUN chmod +x /etc/service/app/run


# Run Command
#
CMD ["/sbin/my_init"]
