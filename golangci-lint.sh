#!/bin/sh
set -e
VERSION='1.28.0'
URL_HEAD='https://github.com/golangci/golangci-lint/releases/download/'
if [ "$china" = '1' ]; then
	URL_HEAD='https://github.wanvi.net/https:/github.com/golangci/golangci-lint/releases/download/'
fi

OS=$(uname -s | tr '[:upper:]' '[:lower:]')

uname_arch() {
  arch=$(uname -m)
  case $arch in
      x86_64) arch="amd64" ;;
      x86) arch="386" ;;
      i686) arch="386" ;;
      i386) arch="386" ;;
      aarch64) arch="arm64" ;;
      armv5*) arch="armv5" ;;
      armv6*) arch="armv6" ;;
      armv7*) arch="armv7" ;;
    esac
  echo ${arch}
}

ARCH=$(uname_arch)
FILE_NAME="golangci-lint-$VERSION-$OS-$ARCH.tar.gz"

is_command() {
  command -v "$1" >/dev/null
}

http_download_curl() {
	local_file=$1
	source_url=$2
	header=$3
	echo $local_file
	echo $source_url
	echo $header
	if [ -z "$header" ]; then
		code=$(curl -w '%{http_code}' -L -o "$local_file" "$source_url")
	else
		code=$(curl -w '%{http_code}' -L -H "$header" -o "$local_file" "$source_url")
	fi
	if [ "$code" != "200" ]; then
		echo "http_download_curl received HTTP status $code"
		return 1
	fi
	return 0
}
http_download_wget() {
	local_file=$1
	source_url=$2
	header=$3
	if [ -z "$header" ]; then
		wget -O "$local_file" "$source_url"
	else
		wget --header "$header" -O "$local_file" "$source_url"
	fi
}
http_download() {
	echo "http_download $2"
	if is_command wget; then
		http_download_wget "$@"
		return
	elif is_command curl; then
		http_download_curl "$@"
		return
	fi
	echo "http_download unable to find wget or curl"
	return 1
}

untar() {
  tarball=$1
  case "${tarball}" in
    *.tar.gz | *.tgz) tar --no-same-owner -xzf "${tarball}" ;;
    *.tar) tar --no-same-owner -xf "${tarball}" ;;
    *.zip) unzip "${tarball}" ;;
    *)
      echo "untar unknown archive format for ${tarball}"
      return 1
      ;;
  esac
}

bin_install() {
	source=$1
	if is_command go; then
		install "$source" $(go env GOPATH)/bin/
		export PATH=$(go env GOPATH)/bin/:$PATH
	else
		mkdir -p "$HOME/bin/"
		install "$source" "$HOME/bin/"
		export PATH=$HOME/bin:$PATH
	fi
}

unix_like_install() {
	filename=$1
	tmpdir=$(mktemp -d)
	url="$URL_HEAD/v$VERSION/$filename"
	echo 'Installing for linux..'
	http_download "${tmpdir}/${filename}" "${url}"
	(cd "${tmpdir}" && untar "${filename}" && bin_install "${tmpdir}/golangci-lint-1.28.0-linux-amd64/golangci-lint")
	rm -rf "${tmpdir}"
}

unix_like_install $FILE_NAME
echo "Complete."
