# Dockerfile for the PDC's Auth service
#
# Base image
#
FROM node


# Set environment variables
#
ENV MAINPORT=3005
ENV CONTROLPORT=3006
ENV FEDERATION=pdc.dev
ENV JURISDICTION=TEST
ENV KEYFILE=/etc/dacs/federations/$FEDERATION/federation_keyfile
ENV ROLEFILE=/etc/dacs/federations/$FEDERATION/roles


# Expose ports for listening
#
EXPOSE $MAINPORT
EXPOSE $CONTROLPORT


# Update, install DACS and create DACS volume
#
RUN apt-get update; \
    apt-get install -y dacs


# Clone and move repo files
#
WORKDIR /tmp/
RUN git clone https://github.com/phydac/auth.git; \
    mv /tmp/auth/api/ /app/; \
    mkdir -p /etc/dacs/federations; \
    mv /tmp/auth/config/federations/* /etc/dacs/federations/; \
    rm -rf /tmp/auth


# Create, provide permissions and  and switch to app user
#
RUN useradd app; \
    chown -R app:app /app/ /etc/dacs/federations/$FEDERATION/
USER app
ENV HOME /app/


# Prepare and run node
#
WORKDIR /app
RUN npm install; \
    dacskey -uj $JURISDICTION -v $KEYFILE; \
    dacspasswd -uj $JURISDICTION -p foo -a foo; \
    echo "foo:admin" > $ROLEFILE
CMD ["npm", "start"]
