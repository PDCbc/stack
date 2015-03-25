FROM node


# Configure Port
ENV PORT 3004
EXPOSE 3004


# Configure Secret
ENV SECRET "Test Secret"

# User Authorization URL
ENV CALLBACK_URL https://auth:3006/auth/callback

# Auth URL
ENV AUTH_MAIN_URL https://auth:3005

# Control URL
ENV AUTH_CONTROL_URL https://auth:3006

# HubAPI URL
ENV HUBAPI_URL https://hubapi:3003

# Allow Self Signed SSL Certs
ENV NODE_TLS_REJECT_UNAUTHORIZED 0

# Install Visualizer Software
#
RUN mkdir -p /app
#WORKDIR /app
#RUN git clone https://github.com/PhyDaC/visualizer.git
ADD ./visualizer /app/visualizer

# Setup nodemon - So it can reload if the file changes.
WORKDIR /app/visualizer
RUN npm install
#RUN rm -rf node-modules
#RUN npm install -g supervisor
#RUN npm install --no-bin-links

#RUN supervisor --watch . -i node_modules init.js

# Install Dependencies then start
CMD ["npm", "start"]
