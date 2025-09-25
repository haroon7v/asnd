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
