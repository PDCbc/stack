# Dockerfile for the PDC's HubAPI service
#
# Base image
#
FROM node


# Configure Mongo URI, secret and enable Node to use self signed SSL certs
#
ENV PORT 3003
ENV MONGO_URI mongodb://hub-db:27017/query_composer_development
ENV AUTH_CONTROL https://auth:3006
ENV ROLES ./roles
#ENV SECRET "Test Secret"
#ENV NODE_TLS_REJECT_UNAUTHORIZED 0


# Expose ports listening for incoming traffic
#
EXPOSE $PORT


# Update
#
RUN apt-get update


# Clone repo
#
WORKDIR /app
RUN git clone https://github.com/PhyDaC/hubapi .


# Create and switch to app user
#
RUN  useradd app; \
     chown -R app:app /app/
USER app
ENV HOME /app/


# Prepare Node and start
#
WORKDIR /app
RUN     rm -rf node-modules;\
        npm install
CMD     ["npm", "start"]
