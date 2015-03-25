# Dockerfile for the PDC's Visualizer service
#
# Base image
#
FROM node


# Update
#
RUN apt-get update


# Configure URLs, secret and enable Node to use self signed SSL certs
#
ENV AUTH_MAIN_URL https://auth:3005
ENV AUTH_CONTROL_URL https://auth:3006
ENV CALLBACK_URL https://auth:3006/auth/callback
ENV HUBAPI_URL https://hubapi:3003
ENV PORT 3004
ENV SECRET "Test Secret"
ENV NODE_TLS_REJECT_UNAUTHORIZED 0


# Clone repo
#
WORKDIR /app
RUN git clone https://github.com/PhyDaC/visualizer.git .


# Prepare Node and start
#
WORKDIR /app
RUN     rm -rf node-modules;\
        npm install
CMD     ["npm", "start"]
