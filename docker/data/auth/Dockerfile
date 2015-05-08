# Dockerfile for the PDC's Auth service
#
# Base image
#
FROM phusion/passenger-nodejs


# Update (non-interactive) and install packages
#
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update; apt-get install -y dacs lynx


# Branch to use from GitHub
#
ENV BRANCH pdc-0.1.0


# Set environment variables
#
ENV MAINPORT=3005
ENV CONTROLPORT=3006
ENV FEDERATION=pdc.dev
ENV JURISDICTION=TEST
ENV DACS=/etc/dacs
ENV KEYFILE=$DACS/federations/$FEDERATION/federation_keyfile
ENV ROLEFILE=$DACS/federations/$FEDERATION/roles


# Clone and move repo files
#
WORKDIR /tmp/
RUN git clone https://github.com/PhysiciansDataCollaborative/auth.git; \
    git -C auth checkout -q $BRANCH
RUN mv /tmp/auth/api/ /app/; \
    mkdir -p $DACS/federations; \
    mv /tmp/auth/config/federations/* $DACS/federations/; \
    rm -rf /tmp/auth


# Prepare and run node
#
WORKDIR /app
RUN npm install
RUN dacskey -uj $JURISDICTION -v $KEYFILE
RUN dacspasswd -uj $JURISDICTION -p oscar -a oscar; \
    echo "oscar:admin" >> $ROLEFILE
RUN chown -R app:app /app/ $DACS/federations/$FEDERATION/


# Create startup script and make it executable
#
RUN mkdir -p /etc/service/auth
RUN ( \
      echo "#!/bin/bash"; \
      echo ""; \
      echo "cd /app"; \
      echo "exec /sbin/setuser app npm start"; \
    )  \
    >> /etc/service/auth/run
RUN chmod +x /etc/service/auth/run


# Expose ports listening for incoming traffic
#
EXPOSE $MAINPORT
EXPOSE $CONTROLPORT


# Run Command
#
CMD ["/sbin/my_init"]
