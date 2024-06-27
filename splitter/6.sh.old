!/bin/bash
#github  and gh setup

 Task: Install dependencies using apt

header2 "install dependencies using apt"
countdown 1

installme git
installme gh

git config --global user.email "abraxas678@gmail.com"
git config --global user.name "abraxas678"

 GitHub authentication and cloning repositories
gh repo list > /dev/null
if [[ $? == 0 ]]; then
  echo "gh logged in"
  sleep 1
else
  gh status
  gh auth refresh -h github.com -s admin:public_key
  gh ssh-key add ./id_ed25519.pub
fi
echo
sleep 2

 Clone repositories if not already cloned
cd
if [[ ! -d $MYHOME/bin ]]; then
gh repo clone abraxas678/bin
sleep 1
gh repo clone abraxas678/.config
sleep 1
fi

 Set permissions for bin scripts
chmod +x ~/bin/*
