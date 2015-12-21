################
# General Jobs #
################

default: configure deploy

configure: config-packages config-mongodb config-bash


###################
# Individual jobs #
###################

base:
	$(call deploy)

deploy:
	$(call deploy)

local:
	$(call deploy)

clean:
	@ sudo docker rm $$( sudo docker ps -a -q ) || true
	@ sudo docker rmi $$( sudo docker images | grep '^<none>' | awk '{print $$3}' )

queries:
	@ $(call start,query_importer)


#################
# Configuration #
#################

# Deploy base.yml, optionally uses a 2nd .YML
#
define deploy
	sudo TAG=$(TAG) docker-compose -f ./compose/base.yml $(YML2) pull
	sudo TAG=$(TAG) docker-compose -f ./compose/base.yml $(YML2) build
	sudo TAG=$(TAG) docker-compose -f ./compose/base.yml $(YML2) up -d
endef


# Start a stopped container ($1), optionally uses a 2nd .YML ($2)
#
define start
	sudo TAG=$(TAG) docker-compose -f ./compose/base.yml $(YML2) start $1
endef


#################
# Configuration #
#################

config-packages:
	@	sudo apt-get update
	@	sudo apt-get install -y \
			linux-image-extra-$$(uname -r) \
			curl
	@	sudo modprobe aufs
	@	wget -qO- https://get.docker.com/ | sh
	@ sudo curl -o /usr/local/bin/docker-compose -L \
			https://github.com/docker/compose/releases/download/1.5.2/docker-compose-`uname -s`-`uname -m`
	@ sudo chmod +x /usr/local/bin/docker-compose


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


config-bash:
	@	if(! grep --quiet 'function dclean()' $${HOME}/.bashrc ); \
		then \
			( \
				echo ""; \
				echo "# Function to quickly enter containers"; \
				echo "#"; \
				echo "function c()"; \
				echo "{"; \
				echo "	sudo docker exec -it \$$1 /bin/bash"; \
				echo "}"; \
				echo ""; \
				echo "# Function to remove stopped containers and untagged images"; \
				echo "#"; \
				echo "function dclean()"; \
				echo "{"; \
				echo "  sudo docker rm \$$( sudo docker ps -a -q )"; \
				echo "  sudo docker rmi \$$( sudo docker images | grep '^<none>' | awk '{print \$$3}' )"; \
				echo "}"; \
				echo ""; \
				echo "# Function to enter a PDC managed Endpoint"; \
				echo "#"; \
				echo "function ep-in()"; \
				echo "{"; \
				echo "	sudo docker exec -it composer ssh -p \$$( expr 44000 + \$$1 ) pdcadmin@localhost"; \
				echo "}"; \
				echo ""; \
				echo "# Aliases to frequently used functions and applications"; \
				echo "#"; \
				echo "alias d='sudo docker'"; \
				echo "alias dc='sudo docker-compose'"; \
				echo "alias i='sudo docker inspect'"; \
				echo "alias l='sudo docker logs -f'"; \
				echo "alias p='sudo docker ps -a'"; \
				echo "alias s='sudo docker ps -a | less -S'"; \
				echo "alias dstats='sudo docker stats \$$( sudo docker ps -a -q )'"; \
			) | tee -a $${HOME}/.bashrc; \
			echo ""; \
			echo ""; \
			echo "Please log in/out for changes to take effect!"; \
			echo ""; \
		fi


################
# Runtime prep #
###############


# Default tag is prod, rename master to latest (~same)
#
TAG ?= prod
ifeq ($(TAG),master)
	TAG=latest
endif


# Default build mode is
#
MODE ?= prod
#YML2 ?= fail
ifeq ($(MODE),prod)
	YML2=-f ./compose/prod.yml
else ifeq ($(MODE),build)
	YML2=-f ./compose/build.yml
else
	YML2=
endif
