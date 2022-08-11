#!/bin/bash
#HUH

function ascii {

	#Added ASCII Art cause why not
	echo	' $$$$$$\                      $$\             $$$$$$\                       $$\               $$\ $$\ '
	echo	'$$  __$$\                     $$ |            \_$$  _|                      $$ |              $$ |$$ |'
	echo	'$$ /  $$ | $$$$$$\   $$$$$$$\ $$$$$$$\          $$ |  $$$$$$$\   $$$$$$$\ $$$$$$\    $$$$$$\  $$ |$$ |'
	echo	'$$$$$$$$ |$$  __$$\ $$  _____|$$  __$$\         $$ |  $$  __$$\ $$  _____|\_$$  _|   \____$$\ $$ |$$ |'
	echo	'$$  __$$ |$$ |  \__|$$ /      $$ |  $$ |        $$ |  $$ |  $$ |\$$$$$$\    $$ |     $$$$$$$ |$$ |$$ |'
	echo	'$$ |  $$ |$$ |      $$ |      $$ |  $$ |        $$ |  $$ |  $$ | \____$$\   $$ |$$\ $$  __$$ |$$ |$$ |'
	echo	'$$ |  $$ |$$ |      \$$$$$$$\ $$ |  $$ |      $$$$$$\ $$ |  $$ |$$$$$$$  |  \$$$$  |\$$$$$$$ |$$ |$$ |'
	echo	'\__|  \__|\__|       \_______|\__|  \__|      \______|\__|  \__|\_______/    \____/  \_______|\__|\__|'
	echo	'                                                                                                      '
	echo	'                                                                                                      '

}






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
