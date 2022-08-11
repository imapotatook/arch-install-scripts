#!/bin/bash
#HUH

{
    echo "Hello"
while true; do 
    read -p "Do you wish to update pacman database? yes or no | " yn
    case $yn in 
         [Yy]* ) sudo pacman -Sy; break;;
         [Nn]* ) exit;;
         * ) echo "Please answer yes or no.";;
    esac
done
}

{
    echo "AYOOOOOOOOO"
}
