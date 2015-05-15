# Dockerfile for the PDC's Visualizer service
#
# Base image
#
FROM phusion/passenger-nodejs


# Copy startup script
#
WORKDIR /app
COPY ./app.sh /app/
RUN chown -R app:app /app


# Create startup script and make it executable
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
