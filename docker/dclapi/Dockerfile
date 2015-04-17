# Dockerfile for the PDC's DCLAPI service
#
# Base image
#
FROM node


# Expose listening ports
#
EXPOSE 3007


# Update
#
RUN apt-get update


# Clone and prep /app/ directory
#
RUN  git clone https://github.com/PhysiciansDataCollaborative/dclapi /app/; \
    git -C /app/ checkout -q pdc-0.1.0
COPY ./dcl.sqlite /app/


# Create and switch to app user
#
RUN  useradd app
RUN  chown -R app:app /app/
USER app
ENV HOME /app/


# Prepare Node and start
#
WORKDIR /app/
RUN     rm -rf node-modules;\
        npm install
CMD     ["npm", "start"]
