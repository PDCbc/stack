# Dockerfile for the PDC's Auth service
#
# Base image
#
FROM node

EXPOSE 30000
# Clone and move repo files
#
WORKDIR /tmp/
RUN git clone https://github.com/phydac/auth.git
RUN mv /tmp/auth/api/ /app/;\
    mkdir -p /etc/dacs/federations;\
    mv /tmp/auth/config/federations/* /etc/dacs/federations/;\
    rm -rf /tmp/auth


# Update, install DACS and create DACS volume
#
RUN apt-get update;\
    apt-get install -y dacs
VOLUME /etc/dacs


# Start the auth service using a script
#
ENTRYPOINT ["/app/auth.sh"]
