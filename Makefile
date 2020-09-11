mypath = $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
TOPSRCDIR ?= $(shell git rev-parse --show-toplevel)
GITREV = $(shell git rev-parse HEAD)

PACKAGE = console-login-helper-messages
PACKAGE_DIR = $(TOPSRCDIR)/$(PACKAGE)
PACKAGESRC_URL = "https://src.fedoraproject.org/rpms/$(PACKAGE)"

PREFIX ?= /usr
SYSCONFDIR ?= /etc
libexecdir ?= $(PREFIX)/libexec

# A starter Makefile which may be useful in a developer workflow for testing
# and iteration.

.PHONY: all
all:
	@echo "(Nothing to build)"

.PHONY: install
install: all
	(set -euo pipefail; \
	# package-specific directories \
	mkdir -p $(DESTDIR)$(PREFIX)/lib/$(PACKAGE)/issue.d; \
	mkdir -p $(DESTDIR)$(PREFIX)/lib/$(PACKAGE)/motd.d; \
	mkdir -p $(DESTDIR)$(SYSCONFDIR)/$(PACKAGE)/issue.d; \
	mkdir -p $(DESTDIR)$(SYSCONFDIR)/$(PACKAGE)/motd.d; \
	# external directories \
	mkdir -p $(DESTDIR)$(SYSCONFDIR)/issue.d; \
	mkdir -p $(DESTDIR)$(SYSCONFDIR)/motd.d; \
	mkdir -p $(DESTDIR)$(SYSCONFDIR)/profile.d; \
	# install \
	# udev rules are not installed by default. \
	# install -DZ -m 0644 usr/lib/udev/rules.d/* \
	# 	  -t $(DESTDIR)$(PREFIX)/lib/udev/rules.d/; \
	install -DZ -m 0644 usr/lib/$(PACKAGE)/* \
		-t $(DESTDIR)$(PREFIX)/lib/$(PACKAGE)/; \
	install -DZ -m 0644 usr/lib/systemd/system/* \
		-t $(DESTDIR)$(PREFIX)/lib/systemd/system/; \
	install -DZ -m 0644 usr/lib/tmpfiles.d/* \
		-t $(DESTDIR)$(PREFIX)/lib/tmpfiles.d/; \
	install -DZ -m 0755 usr/libexec/$(PACKAGE)/* \
		-t $(DESTDIR)$(libexecdir)/$(PACKAGE)/; \
	install -DZ -m 0644 usr/share/$(PACKAGE)/* \
		-t $(DESTDIR)$(PREFIX)/share/$(PACKAGE)/; \
	install -DZ -m 0744 etc/NetworkManager/dispatcher.d/* \
		-t $(DESTDIR)$(SYSCONFDIR)/NetworkManager/dispatcher.d)

# Generate rpms including the content committed at the current git checked-out
# HEAD. The built RPM files are named as
# PACKAGE*-GITREV-<release-number-in-specfile>.rpm.
rpm:
	(set -exuo pipefail; \
	git archive --format=tar --prefix=$(PACKAGE)-$(GITREV)/ $(GITREV) > $(GITREV).tar; \
	test ! -e $(TOPSRCDIR)/$(PACKAGE)/$(PACKAGE).spec && (cd $(TOPSRCDIR) && git clone $(PACKAGESRC_URL)); \
	mv $(GITREV).tar $(TOPSRCDIR)/$(PACKAGE); \
	(cd $(TOPSRCDIR)/$(PACKAGE); \
	sed --in-place -e "s/Version:.*/Version: $(GITREV)/g" $(PACKAGE).spec; \
	sed --in-place -e "s/Source0:.*/Source0: $(GITREV).tar/g" $(PACKAGE).spec; \
	rpmbuild -ba --define "_sourcedir $(PACKAGE_DIR)" \
		--define "_specdir $(PACKAGE_DIR)" \
		--define "_builddir $(PACKAGE_DIR)/.build" \
		--define "_srcrpmdir $(PACKAGE_DIR)/rpms" \
		--define "_rpmdir $(PACKAGE_DIR)/rpms" \
		--define "_buildrootdir $(PACKAGE_DIR)/.buildroot" $(PACKAGE).spec; \
	rm -rf "$(PACKAGE_DIR)/.build";))

# Remove archives and RPM artifacts from previous builds.
clean_rpm:
	rm -rf $(TOPSRCDIR)/$(PACKAGE)/rpms/*; \
	rm -f $(TOPSRCDIR)/$(PACKAGE)/*.tar
