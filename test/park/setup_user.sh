MYUSER="$(gum write --height=1 --prompt=">> " --no-show-help --placeholder="$(whoami)" --header="USER:" --value="$(whoami)")"
echo; echo "MYUSER=$MYUSER"
sleep 0.5
myHEAD="$(gum write --height=1 --prompt=">> " --no-show-help --placeholder="1=head 0=headless" --header="MACHINE:")"
if [[ "$myHEAD" = "headless" ]]; then
    myHEAD="0"
elif [[ "$myHEAD" = "head" ]]; then
    myHEAD="1"
fi
echo "myHEAD=$myHEAD"
sleep 0.5
