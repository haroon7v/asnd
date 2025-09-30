# ASND - AssetSonar Network Discovery

AssetSonar Network Discovery is a package used to setup network discovery server on any on-premises server. It communicates with AssetSonar to sync network devices data.

**Maintained by:** EZO AssetSonar <support@assetsonar.com>

## Building the Debian Package

To build the Debian package, simply run:

```bash
make
```

This will:

1. Fetch the latest AssetSonar connector from the git repository
2. Create a `.deb` package in the `build/` directory

**Note**: The build process automatically fetches the `assetsonar-connector` directory from the master branch of the [open_audit_linux_connector](https://github.com/haroon7v/open_audit_linux_connector) repository.

### Build Requirements

- **Git**: Required to fetch the AssetSonar connector from the repository
- **Internet Connection**: Needed to clone the repository during build
- **Standard Debian Build Tools**: dpkg-dev, build-essential, make

### Runtime Dependencies (Installed Automatically)

When users install the package, these dependencies are automatically installed:

- **ruby-full**: Complete Ruby development environment
- **build-essential**: Essential build tools (gcc, make, etc.)
- **bundler**: Ruby gem dependency manager
- **curl**: HTTP client for API communication
- **cron**: Task scheduler for automated syncing

## Installing the Package

### For End Users

Simply install the `.deb` package using apt (recommended):

```bash
sudo apt install ./asnd_1.0.0-1_all.deb
```

**apt will automatically install all required dependencies** before installing the ASND package.

### Alternative Installation Methods

#### Using dpkg (if apt is not available)

If you must use `dpkg -i`, first install dependencies manually:

```bash
sudo apt install ruby-full build-essential bundler curl cron
sudo dpkg -i asnd_1.0.0-1_all.deb
```

#### Using gdebi (GUI alternative)

```bash
sudo gdebi asnd_1.0.0-1_all.deb
```

**Note**: The package declares all its dependencies in the control file, so any modern package manager will automatically resolve and install them.

## Using ASND

Once installed, you can use the `asnd` command from anywhere in your terminal:

```bash
# Show help message
asnd

# Show help message (explicit)
asnd --help

# Configure ASND with subdomain and token
asnd config mysubdomain mytoken123

# Initialize ASND (requires config to be set up first)
asnd init
```

### Configuration

The `config` subcommand allows you to configure ASND with your AssetSonar subdomain and token:

- **Subdomain**: Your AssetSonar subdomain (e.g., `mysubdomain` for `mysubdomain.assetsonar.com`)
- **Token**: Your AssetSonar API token for network discovery

The configuration process:

1. Validates the subdomain format
2. Checks for existing configuration file and extracts device_id if present
3. Makes a POST request to `https://{subdomain}.assetsonar.com/api/api_integration/verify_network_discovery` with `nd_access_token` in request body
4. If existing device_id is found, includes it in the request body as well
5. Parses the `device_id` from the successful response (HTTP 200)
6. Saves the configuration to `/etc/asnd/config.ini` if verification succeeds
7. Discards the configuration if verification fails or no device_id is returned

**Note**: Configuration requires sudo privileges to write to `/etc/asnd/config.ini`.

### Configuration File Structure

The configuration file `/etc/asnd/config.ini` contains:

```ini
[Assetsonar]
url = https://your-subdomain.assetsonar.com
tag = returned-device-id

[OpenAudit]
sync_enabled = true
url = http://localhost/open-audit/index.php
username = admin
password = password
system_id = returned-device-id
```

### Initialization

The `init` subcommand initializes ASND and performs necessary setup:

- **Prerequisites**: Requires the configuration file to be set up first using the `config` command
- **Configuration Validation**: Checks if the configuration file exists and contains valid Assetsonar and OpenAudit sections
- **OpenAudit Setup**: Invokes the OpenAudit `setup.sh` script and waits for completion
- **AssetSonar Connector Setup**: Installs required dependencies (ruby-full, build-essential, and bundler gem) and configures the connector (files installed by package)
- **Error Handling**: Halts execution if any step fails (config missing/invalid or setup.sh fails)

**Usage:**

```bash
asnd init
```

**Process Flow:**

1. Validates configuration file presence and format
2. Runs OpenAudit setup script (`setup.sh`)
3. Installs required dependencies for AssetSonar connector (ruby-full, build-essential, and bundler gem)
4. Configures AssetSonar connector (files already installed by package)
5. Sets up cron jobs for automated syncing
6. Waits for setup completion and checks exit status
7. Reports success or failure

**Dependencies:**
The `init` command automatically installs required dependencies for the AssetSonar connector:

- **ruby-full**: Complete Ruby development environment
- **build-essential**: Essential build tools (gcc, make, etc.)
- **bundler**: Ruby gem dependency manager

**Supported Systems:**

- **Debian/Ubuntu**: Uses `apt-get` to install packages
- **Other systems**: Not supported - requires Debian/Ubuntu with apt-get

**Note**: The `init` command must be run after successful configuration. It will fail if:

- The configuration file is not present or corrupted
- The OpenAudit setup script (`setup.sh`) is not found
- The setup script exits with a non-zero status
- Required dependencies (ruby-full, build-essential, bundler gem) cannot be installed
- AssetSonar connector files not found (package installation issue)
- System is not Debian/Ubuntu (requires apt-get)

## Package Information

- **Package Name**: asnd
- **Version**: 1.0.0
- **Architecture**: all (architecture independent)
- **Section**: utils
- **Maintainer**: EZO AssetSonar <support@assetsonar.com>

## Files Installed

- `/usr/bin/asnd` - The main executable
- `/usr/share/man/man1/asnd.1` - Manual page

## Uninstalling

To remove the package:

```bash
sudo dpkg -r asnd
```

## Makefile Targets

- `make` or `make build` - Build the Debian package
- `make clean` - Clean build directory
- `make install` - Build and install the package
- `make uninstall` - Remove the package
- `make info` - Show package information and contents

## Customization

To customize the package:

1. Edit `debian/control` to change package metadata
2. Modify `asnd` script to change functionality
3. Update version numbers in `Makefile`
4. Rebuild with `make clean && make`
