#! /bin/bash
echothis() {
  echo;  gum spin --spinner="pulse" --title="" --spinner.foreground="33" --title.foreground="33" sleep 1
  echo -e "╭─ $@"
  echo -e "╰─ [$(date +%H:%M:%S)]"
  gum spin --spinner="pulse" --title="" --spinner.foreground="33" --title.foreground="33" sleep 1
  for i in {1..3}; do
     gum spin --spinner="dot" --title=".$(printf %0.s. $(seq 1 $i))" --spinner.foreground="33" --title.foreground="33" sleep 0.1
  done
}

echothis2() {
  echo -e "└─ 󰄬 $1 installation completed"
}
