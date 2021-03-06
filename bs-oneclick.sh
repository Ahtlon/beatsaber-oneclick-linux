#!/bin/bash
#set -x
bs_install=
cd "$( echo "$bs_install" | tr -d '\r' )"

# figure out what we're installing
uri=$( echo $1 | grep -Eo "^[a-z]+")
# oneclick song
if [[ $uri == "beatsaver" ]]; then
	# move to CustomLevels
	cd "Beat Saber_Data/CustomLevels"
	
	key=$( echo $1 | sed 's/beatsaver:\/\///' )
	
	# check if song already installed first
	if [[ $( ls | grep $key ) ]]; then
		zenity --error --title="OneClick Installer" --text="You already have this song installed!"
		exit 1
	fi
	
	dir=$key"-dir"
	(

		# make directory
		
		mkdir $dir
		cd $dir
		
		# download map
		wget -q https://beatsaver.com/api/download/key/$key
		unzip $key
		rm $key

	) | zenity --progress --pulsate --auto-close --no-cancel \
		--text="Installing song..." --title="OneClick Installer"
		
	# rename directory
	info=$( ls $dir | grep -i info ) # case insensitive!
 	songname=$( grep "_songName" $dir/$info \
				| tr -d "[:space:]" \
				| sed -e 's/^\"_songName\"\:\"//' -e 's/\",$//')
	mv $dir "$songname ($key)"

	zenity --info --text="$( echo $songname | sed 's/\&/\&amp;/' ) installed." --title="OneClick Installer" --width=300 --icon-name="checkbox-checked"

# oneclick saber
elif [[ $uri == "modelsaber" ]]; then
	thing=$( echo $1 | grep -Eo "/[a-z]+/")
	# make sure we're geting a saber!
	if [[ $thing == "/saber/" ]]; then
		# make sure Custom Sabers is installed
		if ! [[ -d "CustomSabers" ]]; then
			zenity --error --title="OneClick Installer" \
			 --text="You don't have the CustomSabers mod installed! You can install it with <span background='gray' foreground='black' font_family='monospace' allow_breaks='false'>./QBeat --install CustomSabers</span>. Visit <a href='https://github.com/geefr/beatsaber-linux-goodies/tree/master/QBeat'>https://github.com/geefr/beatsaber-linux-goodies/tree/master/QBeat</a> if you need QBeat." --width=500
		fi
		
		# install saber
		key=$( echo $1 | sed 's/modelsaber:\/\/saber\///' )
		
		(
		cd "CustomSabers"
		wget -q "https://modelsaber.com/files/saber/$key" 
		) | zenity --progress --pulsate --auto-close --no-cancel \
		--text="Installing saber..." --title="OneClick Installer"
		
		sabername=$( echo $key | sed -e 's/[0-9]*\///' -e 's/.saber//' )
		zenity --info --text="$( echo $sabername| sed 's/\&/\&amp;/' ) installed." --title="OneClick Installer" --width=300 --icon-name="checkbox-checked"
	fi
		
	
fi
