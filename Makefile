
#!/usr/bin/make -f

rpms:
	$(CURDIR)/rpm-build.sh

clean:
	rm -rf $(CURDIR)/console-login-helper-messages-*
	rm -rf $(CURDIR)/rpms/

