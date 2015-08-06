PROJECTVER=15.06-stage
REPOHOST = localhost
REPOUSER = stage
PACKAGE = libmongoc
DOCKER = sipfoundrydev/sipx-docker-base-image:latest
REPOPATH = /var/stage/www-root/sipxecs/${PROJECTVER}/externals/CentOS_6/x86_64/
RPMPATH = RPMBUILD/RPMS/x86_64/*.rpm
SSH_OPTIONS = -o UserKnownHostsFile=./.known_hosts -o StrictHostKeyChecking=no
SCP_PARAMS = ${RPMPATH} ${REPOUSER}@${REPOHOST}:${REPOPATH}
CREATEREPO_PARAMS = ${REPOUSER}@${REPOHOST} createrepo ${REPOPATH}
MKDIR_PARAMS = ${REPOUSER}@${REPOHOST} mkdir -p ${REPOPATH}

all: rpm

rpm-dir:
	@rm -rf RPMBUILD; \
	mkdir -p RPMBUILD/{BUILD,SOURCES,RPMS,SRPMS,SPECS};

rpm: rpm-dir
	pwd > .topdir; cd mongo-c-driver; ../mci.sh

docker-build:
	docker pull ${DOCKER}; \
	docker run -t --rm --name sipx-${PACKAGE}-builder  -v `pwd`:/BUILD ${DOCKER} \
	/bin/sh -c "cd /BUILD && yum update -y && make";


deploy:
	ssh ${SSH_OPTIONS} ${MKDIR_PARAMS}; \
	if [[ $$? -ne 0 ]]; then \
		exit 1; \
	fi; \
	scp ${SSH_OPTIONS} -r ${SCP_PARAMS}; \
	if [[ $$? -ne 0 ]]; then \
		exit 1; \
	fi; \
	ssh ${SSH_OPTIONS} ${CREATEREPO_PARAMS}; \
	if [[ $$? -ne 0 ]]; then \
		exit 1; \
	fi;
