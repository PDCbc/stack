# Dockerfile for the PDC's DCLAPI service
#
# Base image
#
FROM phusion/passenger-nodejs


# Branch to use from GitHub
#
ENV BRANCH master


# Clone repo, copy db, install dependencies, assign to app
#
WORKDIR /app
RUN git clone https://github.com/PhysiciansDataCollaborative/dclapi.git .
RUN git checkout -q $BRANCH
COPY ./dcl.sqlite /app/
RUN npm install
RUN chown -R app:app /app


# Create Hub startup script and make it executable
#
RUN mkdir -p /etc/service/dclapi
RUN ( \
      echo "#!/bin/bash"; \
      echo ""; \
      echo "cd /app"; \
      echo "exec /sbin/setuser app npm start"; \
    )  \
    >> /etc/service/dclapi/run
RUN chmod +x /etc/service/dclapi/run


# Run Command
#
CMD ["/sbin/my_init"]
