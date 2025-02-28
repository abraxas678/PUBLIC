clear
cd $HOME
[[ "$(whoami)" = "root" ]] && MYSUDO="" || MYSUDO="sudo"
mkdir -p ~/.ssh ~/tmp
export DISPLAY=:0
export PATH="$HOME/bin:$PATH"
if confirm_step "Update system packages"; then
    $MYSUDO apt update
    [[ $? = 0 ]] && clear
fi
