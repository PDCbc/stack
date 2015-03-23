FROM node


# Configure Port
ENV PORT 3007
EXPOSE 3007


# Allow Self Signed SSL Certs
ENV NODE_TLS_REJECT_UNAUTHORIZED 0


# Git clone and prep
WORKDIR /app
RUN git clone https://github.com/PhyDaC/dclapi
ADD . /app/dclapi
WORKDIR /app/dclapi

# Install apps
RUN apt-get update;\
    apt-get install -y lynx nano;\
    apt-get clean

# Remove any binaries that might have invalid ELF headers
RUN rm -rf node-modules
RUN npm install

# Install Dependencies then start
CMD ["npm", "start"]
