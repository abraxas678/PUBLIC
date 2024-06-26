#!/bin/bash
##9. Install nvm, node, and yarn
# DNS check
check_dns

# Install nvm, node, and yarn
which nvm > /dev/null
if [[ $? != 0 ]]; then
echo -e "${YELLOW}INSTALL: nvm${RESET}"
countdown 1
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi
which node > /dev/null
if [[ $? != 0 ]]; then
echo -e "${YELLOW}INSTALL: node${RESET}"
countdown 1
nvm install --lts
fi
which yarn > /dev/null
if [[ $? != 0 ]]; then
echo -e "${YELLOW}INSTALL: yarn${RESET}"
countdown 1
npm install --global yarn
fi
