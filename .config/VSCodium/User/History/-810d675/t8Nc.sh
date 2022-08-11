#!/bin/bash
#HUH

{
echo "Do you want to update pacman's databases?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) sudo pacman -Sy; break;;
        No ) exit;;
    esac
done

}
{
echo "Do you wish to syncronize your time?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) sudo timedatectl set-ntp true; break;;
        No ) exit;;
    esac
done
}
