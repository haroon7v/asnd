# Makefile for ASND Debian package

# Package name and version
PACKAGE_NAME = asnd
VERSION = 1.0.0
DEB_VERSION = 1

# Build directory
BUILD_DIR = build
DEB_DIR = $(BUILD_DIR)/$(PACKAGE_NAME)_$(VERSION)-$(DEB_VERSION)

# Default target
all: clean build

# Clean build directory
clean:
	rm -rf $(BUILD_DIR)
	rm -rf assetsonar-connector
	rm -rf temp-repo
	rm -rf open-audit
	rm -rf temp-open-audit
	rm -f open-audit-setup.run

# Build the package
build:
	mkdir -p $(BUILD_DIR)
	@echo "Building Debian package for $(PACKAGE_NAME) version $(VERSION)"
	
	# Fetch AssetSonar connector from git repository
	@echo "Fetching AssetSonar connector from git repository..."
	@if [ -d "assetsonar-connector" ]; then \
		echo "Removing existing assetsonar-connector directory..."; \
		rm -rf assetsonar-connector; \
	fi
	@echo "Cloning repository..."
	git clone git@github.com:haroon7v/open_audit_linux_connector.git temp-repo
	@echo "Extracting assetsonar-connector from master branch..."
	cp -r temp-repo/assetsonar-connector ./
	@echo "Cleaning up temporary repository..."
	rm -rf temp-repo
	
	# Create package directory
	mkdir -p $(DEB_DIR)/usr/bin
	mkdir -p $(DEB_DIR)/usr/share/man/man1
	mkdir -p $(DEB_DIR)/etc/asnd
	mkdir -p $(DEB_DIR)/opt/assetsonar-connector
	mkdir -p $(DEB_DIR)/opt/asnd-setup
	mkdir -p $(DEB_DIR)/DEBIAN
	
	# Copy files
	cp asnd $(DEB_DIR)/usr/bin/
	cp debian/control $(DEB_DIR)/DEBIAN/
	cp debian/postinst $(DEB_DIR)/DEBIAN/
	cp debian/prerm $(DEB_DIR)/DEBIAN/
	
	# Copy AssetSonar connector files
	cp -r assetsonar-connector/* $(DEB_DIR)/opt/assetsonar-connector/
	
	# Build and copy Open-AudIT setup script
	@echo "Building Open-AudIT setup script..."
	@if [ -d "open-audit" ]; then \
		echo "Removing existing open-audit directory..."; \
		rm -rf open-audit; \
	fi
	@echo "Cloning Open-AudIT repository..."
	sh -c "git clone -b feature/46142_network_discovery_setup_improvements https://github.com/bk-az/open-audit.git temp-open-audit"
	@echo "Extracting open-audit from feature branch..."
	cp -r temp-open-audit ./open-audit
	@echo "Cleaning up temporary repository..."
	rm -rf temp-open-audit
	@echo "Building Open-AudIT setup script with makeself..."
	makeself \
		"--tar-extra" \
		"--exclude=.git --exclude=.fuse* --exclude=.phpunit.result.cache --exclude=._spark --exclude=.gitignore" \
		"./open-audit" \
		"$(DEB_DIR)/opt/asnd-setup/open-audit-setup.run" \
		"Open-AudIT 5.6.5" \
		"./install.sh"
	@echo "Open-AudIT setup script built successfully"
	
	# Create man page
	@echo ".TH ASND 1 \"$(shell date '+%B %Y')\" \"ASND $(VERSION)\" \"User Commands\"" > $(DEB_DIR)/usr/share/man/man1/asnd.1
	@echo ".SH NAME" >> $(DEB_DIR)/usr/share/man/man1/asnd.1
	@echo "asnd \\- AssetSonar Network Discovery" >> $(DEB_DIR)/usr/share/man/man1/asnd.1
	@echo ".SH SYNOPSIS" >> $(DEB_DIR)/usr/share/man/man1/asnd.1
	@echo ".B asnd" >> $(DEB_DIR)/usr/share/man/man1/asnd.1
	@echo "[\\fB\\-\\-help\\fR]" >> $(DEB_DIR)/usr/share/man/man1/asnd.1
	@echo ".B asnd" >> $(DEB_DIR)/usr/share/man/man1/asnd.1
	@echo "\\fBconfig\\fR \\fIsubdomain\\fR \\fItoken\\fR" >> $(DEB_DIR)/usr/share/man/man1/asnd.1
	@echo ".SH DESCRIPTION" >> $(DEB_DIR)/usr/share/man/man1/asnd.1
	@echo "AssetSonar Network Discovery is a package used to setup network discovery" >> $(DEB_DIR)/usr/share/man/man1/asnd.1
	@echo "server on any on-premises server. It communicates with AssetSonar to sync" >> $(DEB_DIR)/usr/share/man/man1/asnd.1
	@echo "network devices data." >> $(DEB_DIR)/usr/share/man/man1/asnd.1
	@echo ".SH COMMANDS" >> $(DEB_DIR)/usr/share/man/man1/asnd.1
	@echo ".TP" >> $(DEB_DIR)/usr/share/man/man1/asnd.1
	@echo ".B \\-\\-help" >> $(DEB_DIR)/usr/share/man/man1/asnd.1
	@echo "Show help message" >> $(DEB_DIR)/usr/share/man/man1/asnd.1
	@echo ".TP" >> $(DEB_DIR)/usr/share/man/man1/asnd.1
	@echo ".B config \\fIsubdomain\\fR \\fItoken\\fR" >> $(DEB_DIR)/usr/share/man/man1/asnd.1
	@echo "Configure ASND with subdomain and token. Verifies configuration with" >> $(DEB_DIR)/usr/share/man/man1/asnd.1
	@echo "AssetSonar before saving." >> $(DEB_DIR)/usr/share/man/man1/asnd.1
	@echo ".SH FILES" >> $(DEB_DIR)/usr/share/man/man1/asnd.1
	@echo ".TP" >> $(DEB_DIR)/usr/share/man/man1/asnd.1
	@echo "/etc/asnd/config.ini" >> $(DEB_DIR)/usr/share/man/man1/asnd.1
	@echo "Configuration file containing Assetsonar and OpenAudit settings" >> $(DEB_DIR)/usr/share/man/man1/asnd.1
	@echo ".SH AUTHOR" >> $(DEB_DIR)/usr/share/man/man1/asnd.1
	@echo "EZO AssetSonar <support@assetsonar.com>" >> $(DEB_DIR)/usr/share/man/man1/asnd.1
	
	# Set permissions
	chmod 755 $(DEB_DIR)/usr/bin/asnd
	chmod 644 $(DEB_DIR)/usr/share/man/man1/asnd.1
	chmod 755 $(DEB_DIR)/DEBIAN/postinst
	chmod 755 $(DEB_DIR)/DEBIAN/prerm
	
	# Build the .deb package (requires dpkg-deb, available on Linux/Debian systems)
	@if command -v dpkg-deb >/dev/null 2>&1; then \
		dpkg-deb --build $(DEB_DIR) $(BUILD_DIR)/$(PACKAGE_NAME)_$(VERSION)-$(DEB_VERSION)_all.deb; \
	else \
		echo "Error: dpkg-deb not found. This tool is required to build Debian packages."; \
		echo "Please run this on a Linux/Debian system or install dpkg-deb."; \
		echo "The package structure has been created in $(DEB_DIR)/"; \
		echo "You can manually create the .deb file using: dpkg-deb --build $(DEB_DIR)"; \
		exit 1; \
	fi
	
	@echo ""
	@echo "Package built successfully: $(BUILD_DIR)/$(PACKAGE_NAME)_$(VERSION)-$(DEB_VERSION)_all.deb"
	@echo ""
	@echo "To install the package, run:"
	@echo "  sudo apt install ./$(BUILD_DIR)/$(PACKAGE_NAME)_$(VERSION)-$(DEB_VERSION)_all.deb"
	@echo ""
	@echo "Note: Use 'apt install' instead of 'dpkg -i' to automatically resolve dependencies."
	@echo "If you must use dpkg -i, first install dependencies manually:"
	@echo "  sudo apt install curl ruby ruby-dev gcc make bundler"
	@echo ""
	@echo "To remove the package, run:"
	@echo "  sudo dpkg -r $(PACKAGE_NAME)"

# Install the package (requires sudo)
install: build
	sudo apt install ./$(BUILD_DIR)/$(PACKAGE_NAME)_$(VERSION)-$(DEB_VERSION)_all.deb

# Remove the package (requires sudo)
uninstall:
	sudo dpkg -r $(PACKAGE_NAME)

# Show package info
info: build
	@echo "Package information:"
	dpkg-deb --info $(BUILD_DIR)/$(PACKAGE_NAME)_$(VERSION)-$(DEB_VERSION)_all.deb
	@echo ""
	@echo "Package contents:"
	dpkg-deb --contents $(BUILD_DIR)/$(PACKAGE_NAME)_$(VERSION)-$(DEB_VERSION)_all.deb

.PHONY: all clean build install uninstall info
