# Dockerfile for the PDC's Visualizer service
#
# Base image
#
FROM node


# Update
#
RUN apt-get update


# Clone repo
#
WORKDIR /app
RUN git clone https://github.com/PhyDaC/visualizer.git .


# Create and switch to app user
#
RUN  useradd app
RUN  chown -R app:app /app/
USER app
ENV HOME /app/


# Configure port and URLs
#
ENV PORT 3004
ENV AUTH_MAIN_URL https://auth:3005
ENV AUTH_CONTROL_URL https://auth:3006
ENV CALLBACK_URL https://auth:3006/auth/callback
ENV HUBAPI_URL https://hubapi:3003
ENV SECRET "Test Secret"
ENV NODE_TLS_REJECT_UNAUTHORIZED 0


# Prepare Node and start
#
WORKDIR /app
RUN     rm -rf node-modules;\
        npm install
CMD     ["npm", "start"]
