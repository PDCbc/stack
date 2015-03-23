FROM node

### Configuration Parameters -- You should set these. ###

# Configure Port
ENV PORT 3004
EXPOSE 3004

# Configure Secret
ENV SECRET "Test Secret"

# Configure MONGO_URI
ENV PROVIDER_URL https://hubapi:3003

# User Authorization URL
ENV CALLBACK_URL https://auth:3006/auth/callback

# Auth URL
#ENV AUTH_URL https://auth:300

# HubAPI URL
ENV HUBAPI_URL https://hubapi:3003/

# Allow Self Signed SSL Certs
ENV NODE_TLS_REJECT_UNAUTHORIZED 0


# Install Hub Software
#
RUN mkdir -p /app
WORKDIR /app
RUN git clone https://github.com/PhyDaC/visualizer.git
WORKDIR /app/visualizer

RUN rm -rf node-modules
RUN npm install -g supervisor
RUN npm install --no-bin-links

# Setup nodemon - So it can reload if the file changes.
#RUN npm install -g supervisor
#RUN npm install --no-bin-links
#RUN supervisor --watch . -i node_modules init.js

# Install Dependencies then start
CMD ["npm", "start"]
