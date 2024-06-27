!/bin/bash
#release wait


 Wait for a new release
release_wait2() {
   Get current release version
  CUR_REL=$(curl -L start.yyps.de | grep "echo version:" | sed 's/echo version: NEWv//')
  NEW_REL=$((CUR_REL + 1))

   Print current and new release versions
  echo "CUR_REL: $CUR_REL"
  echo "NEW_REL: $NEW_REL"

  while true; do
    echo "WAITING FOR RELEASE"
    sleep 5
    CUR_REL=$(curl -L start.yyps.de | grep "echo version:" | sed 's/echo version: NEWv//')
    echo "$CUR_REL $NEW_REL"
    [[ $CUR_REL == $NEW_REL ]] && break
  done
echo "Release ready"
exit
}

release_wait() {
   Check if user wants to wait for the next release
  VERS="n"
  read -t 5 -n 1 -p "[W]AIT FOR NEXT RELEASE - v$NEW_REL? >>" VERS
  [[ $VERS == "w" ]] && release_wait2
  echo
}
