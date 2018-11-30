#!/usr/bin/make -f

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir := $(dir $(mkfile_path))

# dnf install -y @buildsys-build rpm-build rpm-devel rpmlint bash coreutils tree diffutils patch rpmdevtools 

srpm:
	$(mkfile_dir)rpm-build.sh $(outdir) $(mkfile_dir)

clean:
	rm -rf $(mkfile_dir)/console-login-helper-messages-*
	rm -rf $(mkfile_dir)/rpms/
	rm -rf $(mkfile_dir)/.buildroot
