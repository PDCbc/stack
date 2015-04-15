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
ENV DACS=/etc/dacs
ENV KEYFILE=$DACS/federations/$FEDERATION/federation_keyfile
ENV ROLEFILE=$DACS/federations/$FEDERATION/roles


# Expose ports listening for incoming traffic
#
EXPOSE $MAINPORT
EXPOSE $CONTROLPORT


# Update and install DACS
#
RUN apt-get update; \
    apt-get install -y dacs \
                       lynx


# Clone and move repo files
#
WORKDIR /tmp/
RUN git clone https://github.com/PhysiciansDataCollaborative/auth.git; \
    git -C auth checkout pdc-0.1.0; \
    mv /tmp/auth/api/ /app/; \
    mkdir -p $DACS/federations; \
    mv /tmp/auth/config/federations/* $DACS/federations/; \
    rm -rf /tmp/auth


# Create, provide permissions and switch to app user
#
RUN useradd app; \
    chown -R app:app /app/ $DACS/federations/$FEDERATION/
USER app
ENV HOME /app/


# Prepare and run node
#
WORKDIR /app
RUN npm install; \
    dacskey -uj $JURISDICTION -v $KEYFILE; \
    dacspasswd -uj $JURISDICTION -p foo -a foo; \
    echo "foo:admin" > $ROLEFILE; \
    dacspasswd -uj $JURISDICTION -p osler -a osler; \
    echo "osler:admin" > $ROLEFILE; \
    dacspasswd -uj $JURISDICTION -p oscar -a oscar; \
    echo "oscar:admin" > $ROLEFILE
CMD ["npm", "start"]
