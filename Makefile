NODENAME_MONGO=mongodb
AUTHOR=tleijtens
NAME=mongo
MONGODATA=mongodata
MONGOCONFIG=mongoconfig
PWD=/dockerbackup
NETWORKNAME=worldnet
NETWORKID=42
NADDR=11
SUBNET=10.0.42
VERSION=latest

start:	mongo

stop:
	docker stop $(NODENAME_MONGO)

clean:
	docker rm -f $(NODENAME_MONGO)

cleanrestart:	clean start

network:
	docker network create --subnet $(SUBNET).0/24 --gateway $(SUBNET).254 $(NETWORKNAME)

datavolumes:
	docker run -d -v $(MONGODATA):/data/db --name $(MONGODATA) --entrypoint /bin/echo debian:wheezy
	docker run -d -v $(MONGOCONFIG):/data/configdb --name $(MONGOCONFIG) --entrypoint /bin/echo debian:wheezy

backup:
	docker run --rm --volumes-from $(MONGODATA) -v $(PWD):/backup debian:wheezy bash -c "tar zcvf /backup/$(MONGODATA).tgz data/db"
	docker run --rm --volumes-from $(MONGOCONFIG) -v $(PWD):/backup debian:wheezy bash -c "tar zcvf /backup/$(MONGOCONFIG).tgz data/configdb"

restore:
	docker run --rm --volumes-from $(MONGODATA) -v $(PWD):/backup debian:wheezy bash -c "tar zxvf backup/$(MONGODATA).tgz"
	docker run --rm --volumes-from $(MONGOCONFIG) -v $(PWD):/backup debian:wheezy bash -c "tar zxvf backup/$(MONGOCONFIG).tgz"

rmnetwork:
	docker network rm $(NETWORKNAME)

help:
	docker run -i $(NAME):$(VERSION) help

mongo:
	docker run -d --net $(NETWORKNAME) --ip $(SUBNET).$(NADDR) -e SUBNET=$(SUBNET) --volumes-from=$(MONGODATA) --volumes-from=$(MONGOCONFIG) -p 27017:27017 --name $(NODENAME_MONGO) mongo:latest mongod

rmmongo:
	docker rm -f $(NODENAME_MONGO)

rmdatavolumes:
	docker rm -f $(MONGODATA)
	docker volume rm $(MONGODATA)
	docker rm -f $(MONGOCONFIG)
	docker volume rm $(MONGOCONFIG)
