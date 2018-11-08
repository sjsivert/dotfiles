xargs -a <(awk '! /^ *(#|$)/' "server-requirements.txt") -r -- sudo apt-get install

