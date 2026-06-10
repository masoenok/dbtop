#!/bin/sh
# dbtop installer — downloads the matching binary from the latest release and
# installs it to /usr/local/bin/dbtop.
#   curl -fsSL https://raw.githubusercontent.com/masoenok/dbtop/main/install.sh | sh
set -e

repo="masoenok/dbtop"
dest="${DBTOP_DEST:-/usr/local/bin/dbtop}"

arch=$(uname -m)
case "$arch" in
	x86_64 | amd64) bin="dbtop-linux-amd64" ;;
	aarch64 | arm64) bin="dbtop-linux-arm64" ;;
	*) echo "Unsupported architecture: $arch" >&2; exit 1 ;;
esac

if [ "$(uname -s)" != "Linux" ]; then
	echo "dbtop binaries are built for Linux. Current system: $(uname -s)" >&2
	exit 1
fi

url="https://raw.githubusercontent.com/$repo/main/bin/$bin"
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

echo "Downloading $bin ..."
if command -v curl >/dev/null 2>&1; then
	curl -fsSL "$url" -o "$tmp"
elif command -v wget >/dev/null 2>&1; then
	wget -qO "$tmp" "$url"
else
	echo "Neither curl nor wget found." >&2; exit 1
fi
chmod +x "$tmp"

# install to $dest (sudo if needed)
if [ -w "$(dirname "$dest")" ]; then
	install -m 0755 "$tmp" "$dest"
else
	echo "Installing to $dest (sudo) ..."
	sudo install -m 0755 "$tmp" "$dest"
fi

echo "Done: $dest"
echo "Start with:  dbtop   (uses ~/.my.cnf)   or   dbtop -h <host> -u <user> -p"
