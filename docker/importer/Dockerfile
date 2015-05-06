# Dockerfile for the PDC's QueryImporter service
#
# Base image
#
FROM phusion/passenger-nodejs


# Clone repo
#
WORKDIR /app
#RUN git clone https://github.com/PhysiciansDataCollaborative/QueryImporter .
COPY ./QueryImporter .


# Prepare and run node
#
WORKDIR /app
RUN npm install
RUN npm install assert async fs minimist mongodb mongoose --save
RUN nodejs queryImporter import --mongo-host=network_hubdb --mongo-db=query_composer_development


# Create startup script and make it executable
#
RUN mkdir -p /etc/service/app
RUN ( \
      echo "#!/bin/bash"; \
      echo ""; \
      echo "cd /app"; \
      echo "git pull"
      echo "nodejs queryImporter import --mongo-host=network_hubdb --mongo-db=query_composer_development"; \
    )  \
    >> /etc/service/app/run
RUN chmod +x /etc/service/app/run


# Run Command
#
CMD ["/sbin/my_init"]
