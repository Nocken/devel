ARCH := x86
INSTALL_MOD_PATH := $(shell echo /tmp/modules-$$$$)
Q := @

export ARCH
export INSTALL_MOD_PATH

all:

modules_install:
	$(Q)mkdir -p $(INSTALL_MOD_PATH)
	$(Q)make -C linux $@ && { \
		./setenv.sh sync_root $(INSTALL_MOD_PATH); \
		cd disks/initramfs; \
		rm -rf skel/lib/modules; \
	       	cp -aT $(INSTALL_MOD_PATH) skel; \
	      	./build.sh; \
		}
	$(Q)rm -rf $(INSTALL_MOD_PATH)

%:
	$(Q)make -C linux $@
