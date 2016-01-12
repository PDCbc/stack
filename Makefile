################
# General Jobs #
################

default: configure deploy

configure: config-packages config-mongodb config-bash


###################
# Individual jobs #
###################

deploy:
	@	sudo TAG=$(TAG) docker-compose $(YML) pull
	@	sudo TAG=$(TAG) docker-compose $(YML) build
	@	sudo TAG=$(TAG) docker-compose $(YML) up -d

queries:
	@	sudo TAG=$(TAG) docker-compose $(YML) start query_importer

config-docker:
	@ wget -qO- https://raw.githubusercontent.com/PDCbc/devops/master/docker_setup.sh | sh

config-mongodb:
	@	( echo never | sudo tee /sys/kernel/mm/transparent_hugepage/enabled )> /compose/null
	@	( echo never | sudo tee /sys/kernel/mm/transparent_hugepage/defrag )> /compose/null
	@	if(! grep --quiet 'never > /sys/kernel/mm/transparent_hugepage/enabled' /etc/rc.local ); \
		then \
			sudo sed -i '/exit 0/d' /etc/rc.local; \
			( \
				echo ''; \
				echo '# Disable Transparent Hugepage, for Mongo'; \
				echo '#'; \
				echo 'echo never > /sys/kernel/mm/transparent_hugepage/enabled'; \
				echo 'echo never > /sys/kernel/mm/transparent_hugepage/defrag'; \
				echo ''; \
				echo 'exit 0'; \
			) | sudo tee -a /etc/rc.local; \
		fi; \
		sudo chmod 755 /etc/rc.local


################
# Runtime prep #
###############

# Default tag is prod, rename master to latest (~same)
#
TAG ?= prod
ifeq ($(TAG),master)
	TAG=latest
endif

# Default YML is base.yml
#
YML ?= -f ./docker-compose.yml
ifeq ($(MODE),prod)
	YML += -f ./compose/prod.yml
else ifeq ($(MODE),build)
	YML += -f ./dev/dev.yml
endif
