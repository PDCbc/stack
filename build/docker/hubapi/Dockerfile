FROM node

# Configure Port
#
ENV PORT 3003
EXPOSE 3003

# Configure Secret
#
ENV SECRET "Test Secret"

# Configure MONGO_URI
#
ENV MONGO_URI mongodb://hub-db:27017/query_composer_development

# Allow Self Signed SSL Certs
#
ENV NODE_TLS_REJECT_UNAUTHORIZED 0

# Git clone and prep
#
ADD . /app
WORKDIR /app
RUN git clone https://github.com/PhyDaC/hubapi
WORKDIR /app/hubapi

# Update
#
RUN apt-get update

# Remove any binaries that might have invalid ELF headers
#
RUN rm -rf node-modules
RUN npm install

# Install Dependencies then start
CMD ["npm", "start"]
