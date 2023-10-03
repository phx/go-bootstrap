#!/bin/bash

if uname -s | grep -qE 'Linux' >/dev/null 2>&1; then
  LINUX=1
elif uname -s | grep -qE 'Darwin' >/dev/null 2>&1; then
  DARWIN=1
else
  echo "this script is not supported by your system."
  exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "install 'curl' and try again."
  exit 1
fi

BASE_URL='https://go.dev'
HTML="$(curl -skL "${BASE_URL}/dl/")"
if [ "$LINUX" = "1" ] ; then
  DOWNLOAD_URL="${BASE_URL}$(echo "${HTML}" | grep href | grep linux | grep amd64 | grep 'tar.gz' | head -1 | cut -d '"' -f4)"
elif [ "$DARWIN" = "1" ]; then
  DOWNLOAD_URL="${BASE_URL}$(echo "${HTML}" | grep href | grep darwin | grep amd64 | grep 'tar.gz' | head -1 | cut -d '"' -f6)"
fi
TMP="$(mktemp -d)"

cd "$TMP" || exit 1
echo "downloading golang from ${DOWNLOAD_URL}..."
curl -skL "$DOWNLOAD_URL" | tar xz

if [ ! -d go ]; then
  echo
  echo "oops. was expecting a go directory here. sorry."
  echo
  ls -lh
  exit 1
fi

echo 'moving go to the default $GOPATH location at ~/go...'
mv ~/go ~/go.bak >/dev/null 2>&1
mv -v go ~/

echo
echo 'setting up environment variables...'
for i in profile bashrc bash_profile zshrc; do
  if [ -e "${HOME}/.${i}" ]; then
    echo >> "${HOME}/.${i}"
    echo "export GOPATH=${HOME}/go" >> "${HOME}/.${i}"
    echo 'export PATH="${PATH}:${GOPATH}/bin"' >> "${HOME}/.${i}"
  fi
done

# disabling glide install for mac at the moment
if [[ "$LINUX" = 1 ]]; then
  echo
  echo 'installing latest release of glide for dependency management...'
  GLIDE_URL="$(curl -skL 'https://api.github.com/repos/Masterminds/glide/releases' | grep 'browser_download_url' | grep 'linux-amd64' | head -1 | cut -d'"' -f4)"
  curl -skL "$GLIDE_URL" | tar xz
  echo
  echo "moving 'glide' into ~/go/bin/ since it will be in your \$PATH now..."
  mv -v linux-amd64/glide ~/go/bin/ && rm -rf linux-amd64
  echo
  instructions="$(cat <<EOT
'glide init' creates an initial 'glide.yaml' file and gets us ready to use it.
'glide get [package]' is like 'go get'. it installs a package and records it in the 'glide.yaml' and 'glide.lock' files.
'glide update' takes the sometimes non-specific version numbers in 'glide.yaml' and turns them into actual version hashes stored in 'glide.lock' and installs the packages.
'glide install' installs the specific package versions remembered by the 'glide.lock' file.
EOT
)"
  echo "$instructions" | tee ~/go/glide.help
  echo
  echo "if you need this reference again, just 'cat ~/go/glide.help'."
  echo
  echo "you will need to reload your rcfile to have the new environment variables take effect."
fi

# hacky workaround to get shell because $SHELL doesn't report right in many cases:
shell="$(grep "$USER" /etc/passwd | awk -F '/' '{print $NF}')"
if [ "$shell" = "bash" ]; then
  echo "just simply run 'source ~/.bashrc' and you should be in business."
elif [ "$shell" = "zsh" ]; then
  echo "just simply run 'source ~/.zshrc' and you should be in business."
elif [ "$shell" = "sh" ]; then
  echo "just simply run '. ~/.profile' and you should be in business."
fi
echo
echo 'kiss kiss all done. bye bye.'
