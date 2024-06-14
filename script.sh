#!/bin/bash
clear
read -p "PROCESS_COUNT: >> " -n 2 PROCESS_COUNT
[[ -z $PROCESS_COUNT ]] && PROCESS_COUNT=5
cd /home/abra/VIDEO
clear

header(){
  rich -p "$@" -s yellow -a rounded -e  
}

header2(){
  rich -p "$@" -s green -a rounded -S green -e
}

header "collect $PROCESS_COUNT files from jd:PROCESS"
echo
sleep 1
rclone lsf --files-only --include="*.mp4" jd:PROCESS | tail -n $PROCESS_COUNT >myfiles
header2 "DONE: $PROCESS_COUNT FILES COLLECTED"
echo

y=1
while IFS= read -r line; do
   header2 "[$y/$PROCESS_COUNT] MOVE JD:PROCESS -> VIDEO/RENAME:  $line"
   sudo rclone  --password-command="/home/abra/bin/age --decrypt -i /home/abra/.ssh/age-keys.txt /home/abra/.config/rc.age" move jd:PROCESS/$line /home/abra/VIDEO/RENAME -P --update --progress-terminal-title --stats-one-line
   y=$((y+1))
   echo
done <myfiles 

cd /home/abra/VIDEO/RENAME 
echo; 
header "RENAME"
$HOME/bin/video_renamer.sh 
sleep 1
header2 "RENAME DONE"
sleep 2
echo
rclone lsf --files-only /home/abra/VIDEO/RENAME
echo; 
$HOME/bin/countdown.sh 5
header "MOVE VIDEO/RENAME -> VIDEO/CONVERT "
sudo rclone --password-command="/home/abra/bin/age --decrypt -i /home/abra/.ssh/age-keys.txt /home/abra/.config/rc.age" move /home/abra/VIDEO/RENAME /home/abra/VIDEO/CONVERT --include="*.mp4" -P --update   --progress-terminal-title --stats-one-line
echo
rclone lsf --files-only /home/abra/VIDEO/CONVERT
echo; 
$HOME/bin/countdown.sh 5
echo; header "MOVE FINISHED FILES (vconv) TO VIDEO/DONE"
mv /home/abra/VIDEO/CONVERT/*vconv*.mp4 /home/abra/VIDEO/DONE
mv /home/abra/VIDEO/SMALLER/*vconv*.mp4 /home/abra/VIDEO/DONE
echo
rclone lsf --files-only /home/abra/VIDEO/DONE
echo; 
$HOME/bin/countdown.sh 50
echo; header "move VIDE/DONE to jd:PROCESS_DONE"
sudo rclone --password-command="/home/abra/bin/age --decrypt -i /home/abra/.ssh/age-keys.txt /home/abra/.config/rc.age" lsf --files-only /home/abra/VIDEO/DONE --include="*_vconv*" --include="*.mp4" >finished_files
COUNT=$(cat finished_files | wc -l)
rich -p "$(cat finished_files)" -s blue -a heavy -e --title "COUNT: $COUNT" --left --text-left
sudo rclone --password-command="/home/abra/bin/age --decrypt -i /home/abra/.ssh/age-keys.txt /home/abra/.config/rc.age" move /home/abra/VIDEO/DONE jd:PROCESS_DONE --include="*_vconv*" --include="*.mp4" -P --update  --progress-terminal-title --stats-one-line
echo
rm -f finished_files
