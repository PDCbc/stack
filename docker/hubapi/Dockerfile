# Dockerfile for the PDC's HubAPI service
#
# Base image
#
FROM node


# Configure port, secret, Mongo URI and allow Node to use self signed SSL certs
#
ENV PORT 3003


# Update
#
RUN apt-get update


# Configure Mongo URI, secret and enable Node to use self signed SSL certs
#
ENV MONGO_URI mongodb://hub-db:27017/query_composer_development
ENV SECRET "Test Secret"
ENV NODE_TLS_REJECT_UNAUTHORIZED 0


# Git clone and prep
#
WORKDIR /app
RUN git clone https://github.com/PhyDaC/hubapi .


# Prepare Node and start
#
WORKDIR /app
RUN     rm -rf node-modules;\
        npm install
CMD     ["npm", "start"]
