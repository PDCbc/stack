# Dockerfile for the PDC's Visualizer service
#
# Base image
#
FROM phusion/passenger-nodejs


# Branch to use from GitHub
#
ENV BRANCH pdc-0.1.0


# Configure port and URLs
#
ENV PORT 3004
ENV HUBAPI_URL https://hapi:3003
ENV AUTH_MAIN_URL https://auth:3005
ENV AUTH_CONTROL_URL https://auth:3006
ENV CALLBACK_URL https://auth:3006/auth/callback
ENV SECRET "Test Secret"
ENV NODE_TLS_REJECT_UNAUTHORIZED 0


# Expose ports listening for incoming traffic
#
EXPOSE $PORT


# Clone repo, assign to app
#
WORKDIR /app
RUN git clone https://github.com/PhysiciansDataCollaborative/visualizer.git .
RUN git checkout -q $BRANCH
RUN chown -R app:app /app


# Create startup script and make it executable
#
RUN mkdir -p /etc/service/visualizer
RUN ( \
      echo "#!/bin/bash"; \
      echo ""; \
      echo "cd /app"; \
      echo "npm config set python /usr/bin/python"; \
      echo "npm config set home /app"; \
      echo "npm install"; \
      echo "exec /sbin/setuser app npm start"; \
    )  \
    >> /etc/service/visualizer/run
RUN chmod +x /etc/service/visualizer/run


# Run Command
#
CMD ["/sbin/my_init"]
