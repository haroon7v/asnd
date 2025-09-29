# ASND - AssetSonar Network Discovery

AssetSonar Network Discovery is a package used to setup network discovery server on any on-premises server. It communicates with AssetSonar to sync network devices data.

**Maintained by:** EZO AssetSonar <support@assetsonar.com>

## Building the Debian Package

To build the Debian package, simply run:

```bash
make
```

This will create a `.deb` package in the `build/` directory.

## Installing the Package

To install the package on your system:

```bash
sudo dpkg -i build/asnd_1.0.0-1_all.deb
```

## Using ASND

Once installed, you can use the `asnd` command from anywhere in your terminal:

```bash
# Show help message
asnd

# Show help message (explicit)
asnd --help

# Configure ASND with subdomain and token
asnd config mysubdomain mytoken123
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
