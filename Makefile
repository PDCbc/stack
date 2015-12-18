################
# General Jobs #
################

default: configure base

configure: config-packages config-mongodb config-bash


###################
# Individual jobs #
###################

base:
	@ $(call deploy,prod)

prod:
	@ $(call deploy,prod,-f ./compose/prod.yml)

master:
	@ $(call deploy,latest)

dev:
	@ $(call deploy,dev)

local:
	@ [ -s ./compose/build.yml ]|| \
		sudo cp ./compose/build.yml-sample ./compose/build.yml
	@ $(call deploy,prod,-f ./compose/build.yml)

clean:
	@ sudo docker rm $$( sudo docker ps -a -q ) || true
	@ sudo docker rmi $$( sudo docker images | grep '^<none>' | awk '{print $$3}' )

queries:
	@ sudo docker-compose start query_importer

local-queries:
	@ sudo docker-compose start -f ./compose/base.yml -f ./compose/build.yml query_importer


#################
# Configuration #
#################

# Deploy prod, master, dev or local
#
define deploy
		# 1=TAG (required)
		# 2=2ndary .YML file (optional)
		#
		sudo TAG=$1 docker-compose -f ./compose/base.yml $2 pull
		sudo TAG=$1 docker-compose -f ./compose/base.yml $2 build
		sudo TAG=$1 docker-compose -f ./compose/base.yml $2 stop
		sudo TAG=$1 docker-compose -f ./compose/base.yml $2 rm -f
		sudo TAG=$1 docker-compose -f ./compose/base.yml $2 up -d
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
