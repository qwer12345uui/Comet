ROOTLESS ?= 0
ROOTHIDE ?= 0

# Build config
ARCHS = arm64 arm64e
THEOS_DEVICE_IP = localhost -p 2222
INSTALL_TARGET_PROCESSES = Preferences
TARGET ?= iphone:clang:latest:15.0
PACKAGE_VERSION = 1.1.0

# Keep the package layout root-relative. Theos applies the rootless/rootHide
# install prefix; RootHide must never bake a fixed /var/jb path into Mach-O.
COMET_INSTALL_PATH = /Library/Frameworks
ifeq ($(ROOTHIDE),1)
	THEOS_PACKAGE_SCHEME = roothide
	Comet_XCODEFLAGS = SWIFT_ACTIVE_COMPILATION_CONDITIONS="ROOTHIDE" GCC_PREPROCESSOR_DEFINITIONS="ROOTHIDE=1"
	Comet_XCODEFLAGS += OTHER_LDFLAGS="$(inherited) -L$(THEOS)/vendor/lib -lroothide"
	Comet_XCODEFLAGS += LD_RUNPATH_SEARCH_PATHS="$(inherited) @loader_path/Frameworks @loader_path/.jbroot/Library/Frameworks"
	COMET_DYLIB_INSTALL_NAME = @loader_path/.jbroot/Library/Frameworks/Comet.framework/Comet
	MOVE_TO_THEOS_PATH = $(THEOS)/lib/iphone/roothide/
	PKG_NAME_SUFFIX = (RootHide)
else ifeq ($(ROOTLESS),1)
	THEOS_PACKAGE_SCHEME = rootless
	Comet_XCODEFLAGS = SWIFT_ACTIVE_COMPILATION_CONDITIONS="ROOTLESS" GCC_PREPROCESSOR_DEFINITIONS="ROOTLESS=1"
	COMET_DYLIB_INSTALL_NAME = @rpath/Comet.framework/Comet
	MOVE_TO_THEOS_PATH = $(THEOS)/lib/iphone/rootless/
	PKG_NAME_SUFFIX = (Rootless)
else
	Comet_XCODEFLAGS = SWIFT_ACTIVE_COMPILATION_CONDITIONS=""
	COMET_DYLIB_INSTALL_NAME = /Library/Frameworks/Comet.framework/Comet
	MOVE_TO_THEOS_PATH = $(THEOS)/lib/
endif

include $(THEOS)/makefiles/common.mk

XCODEPROJ_NAME = Comet
Comet_XCODEFLAGS += LD_DYLIB_INSTALL_NAME=$(COMET_DYLIB_INSTALL_NAME)
Comet_XCODEFLAGS += DYLIB_INSTALL_NAME_BASE=$(COMET_DYLIB_INSTALL_NAME)
Comet_XCODEFLAGS += DWARF_DSYM_FOLDER_PATH=$(THEOS_OBJ_DIR)/dSYMs
Comet_XCODEFLAGS += CONFIGURATION_BUILD_DIR=$(THEOS_OBJ_DIR)/
Comet_XCODEFLAGS += BUILD_LIBRARY_FOR_DISTRIBUTION=YES

include $(THEOS)/makefiles/xcodeproj.mk

#override THEOS_PACKAGE_NAME := com.ginsu.comet-$(PKG_ARCHITECTURE)

before-package::
	# Append values to control file
	$(ECHO_NOTHING)sed -i '' \
		-e 's/\$${PKG_NAME_SUFFIX}/$(PKG_NAME_SUFFIX)/g' \
		$(THEOS_STAGING_DIR)/DEBIAN/control$(ECHO_END)
	
ifneq ($(filter 1,$(ROOTLESS) $(ROOTHIDE)),)
	# Xcode outputs the framework outside the Theos staging tree. Keep the
	# staged path root-relative; Theos applies the selected package scheme.
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)$(COMET_INSTALL_PATH)$(ECHO_END)
	$(ECHO_NOTHING)if [ -d "$(THEOS_OBJ_DIR)/Comet.framework" ]; then mv "$(THEOS_OBJ_DIR)/Comet.framework" "$(THEOS_STAGING_DIR)$(COMET_INSTALL_PATH)"; fi$(ECHO_END)
endif

	# Copy to theos/lib
	$(ECHO_NOTHING)rm -rf $(MOVE_TO_THEOS_PATH)Comet.framework/$(ECHO_END)
	$(ECHO_NOTHING)cp -r $(THEOS_STAGING_DIR)$(COMET_INSTALL_PATH)/Comet.framework $(MOVE_TO_THEOS_PATH)$(ECHO_END)

before-all::
	$(ECHO_NOTHING)rm -rf $(THEOS_STAGING_DIR)$(COMET_INSTALL_PATH)$(ECHO_END)
	$(ECHO_NOTHING)rm -rf $(THEOS_OBJ_DIR)$(ECHO_END)
