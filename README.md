linux-domain-setup:

sets up a Microsoft Windows(TM) compatable domain server on a linux machine

Currently, this script only works with debian

Tested on a fresh install of debian on AWS

to run the script, simply call it with sudo / root

IMPORTANT: make sure to prepend the script with its desired variables, or you will have a broken install!

eg:

$ export MAIND=mymaindomain.tld; export SUBD=mysubdomain; sudo ./linux-domain-setup.sh

OR

# export MAIND=mymaindomain.tld; export SUBD=mysubdomain; ./linux-domain-setup.sh
