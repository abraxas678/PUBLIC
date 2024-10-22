#!/bin/bash
#04. akeyless setup
curl -o akeyless https://akeyless-cli.s3.us-east-2.amazonaws.com/cli/latest/production/cli-linux-amd64
chmod +x akeyless
mv akeyless /home/abrax/bin/
echo; echo; echo "ACCESS ID p-z887athlsakpim"; echo; echo
/home/abrax/bin/akeyless configure --access-id p-mcidcla45c0cam --access-type oidc --profile 'github-oidc'
