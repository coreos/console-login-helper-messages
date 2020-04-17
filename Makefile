mypath = $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
topsrcdir = $(shell git rev-parse --show-toplevel)
GITREV = $(shell git rev-parse HEAD)

PACKAGE ?= $(shell basename $(topsrcdir))
PACKAGE_DIR = $(topsrcdir)/$(PACKAGE)
PACKAGESRC_URL = "https://src.fedoraproject.org/rpms/$(PACKAGE)"

# A starter Makefile which may be useful in a developer workflow for testing
# and iteration.

# Generate rpms including the content committed at the current git checked-out
# HEAD. The built RPM files are named as
# PACKAGE*-GITREV-<release-number-in-specfile>.rpm.
rpm:
	(set -ex; \
	git archive --format=tar --prefix=$(PACKAGE)-$(GITREV)/ $(GITREV) > $(GITREV).tar; \
	test ! -e $(PACKAGE)/$(PACKAGE).spec && git clone $(PACKAGESRC_URL); \
	mv $(GITREV).tar $(PACKAGE); \
	(cd $(PACKAGE); \
	sed --in-place -e "s/Version:.*/Version: $(GITREV)/g" $(PACKAGE).spec; \
	sed --in-place -e "s/Source0:.*/Source0: $(GITREV).tar/g" $(PACKAGE).spec; \
	rpmbuild -ba --define "_sourcedir $(PACKAGE_DIR)" \
		--define "_specdir $(PACKAGE_DIR)" \
		--define "_builddir $(PACKAGE_DIR)/.build" \
		--define "_srcrpmdir $(PACKAGE_DIR)/rpms" \
		--define "_rpmdir $(PACKAGE_DIR)/rpms" \
		--define "_buildrootdir $(PACKAGE_DIR)/.buildroot" $(PACKAGE).spec; \
	rm -rf "$(PACKAGE_DIR)/.build";))
