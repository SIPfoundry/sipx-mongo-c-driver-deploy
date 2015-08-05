all: rpm

rpm-dir:
	@rm -rf RPMBUILD; \
	mkdir -p RPMBUILD/{BUILD,SOURCES,RPMS,SRPMS,SPECS};

rpm: rpm-dir
	pwd > .topdir; cd mongo-c-driver; ../mci.sh
