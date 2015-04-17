# Dockerfile for the PDC's Visualizer service
#
# Base image
#
FROM node


# Configure port and URLs
#
ENV PORT 3004
ENV HUBAPI_URL https://hubapi:3003
ENV AUTH_MAIN_URL https://auth:3005
ENV AUTH_CONTROL_URL https://auth:3006
ENV CALLBACK_URL https://auth:3006/auth/callback
ENV SECRET "Test Secret"
ENV NODE_TLS_REJECT_UNAUTHORIZED 0


# Expose ports listening for incoming traffic
#
EXPOSE $PORT


# Update
#
RUN apt-get update


# Clone repo
#
WORKDIR /app
RUN git clone https://github.com/PhysiciansDataCollaborative/visualizer.git .; \
    git checkout -q pdc-0.1.0


# Create and switch to app user
#
RUN  useradd app; \
     chown -R app:app /app/
USER app
ENV HOME /app/


# Prepare Node and start
#
WORKDIR /app
RUN     rm -rf node-modules; \
        npm install
CMD     ["npm", "start"]
