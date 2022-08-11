#!/bin/bash
#HUH

{
echo "Do you wish to install this program?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) sudo pacman -Sy; break;;
        No ) exit;;
    esac
done

}

{
    echo "AYOOOOOOOOO"
}
