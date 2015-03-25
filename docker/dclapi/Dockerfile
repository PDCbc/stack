# Dockerfile for the PDC's DCLAPI service
#
# Base image
#
FROM node


# Allow Self Signed SSL Certs
#
ENV NODE_TLS_REJECT_UNAUTHORIZED 0


# Update
#
RUN apt-get update


# Clone and prep /app/ directory
#
WORKDIR /app
RUN     git clone https://github.com/PhyDaC/dclapi .
COPY    ./dcl.sqlite /app/


# Prepare Node and start
#
WORKDIR /app
RUN     rm -rf node-modules;\
        npm install
CMD     ["npm", "start"]
