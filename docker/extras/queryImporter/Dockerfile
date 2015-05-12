# Dockerfile for the PDC's queryImporter service
#
# Base image
#
FROM phusion/passenger-nodejs


# Update to nodejs 0.12.x
#
RUN curl -sL https://deb.nodesource.com/setup_0.12 | sudo bash -
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update; apt-get install -y nodejs


# Clone repo, assign to app
#
WORKDIR /app
RUN git clone https://github.com/PhysiciansDataCollaborative/queryImporter.git .
RUN npm install

# Run Command
#
CMD ["/sbin/my_init"]
