#!/bin/bash

# Copyright 2011-2013 Alexander von Gluck IV
# Released under the terms of the MIT license

echo "Linux System Audit 0.2"

fg_black="$(tput setaf 0)"
fg_red="$(tput setaf 1)"
fg_green="$(tput setaf 2)"
fg_yellow="$(tput setaf 3)"
fg_blue="$(tput setaf 4)"
fg_magenta="$(tput setaf 5)"
fg_cyan="$(tput setaf 6)"
fg_white="$(tput setaf 7)"
reset="$(tput sgr0)"

function debchecker {
	echo -n "-- Checking ${1}... "
	if dpkg-query -l "$1" 2>/dev/null | grep -q ^.i; then
		debsums -c ${1}
		if [ $? -ne 0 ]; then
			echo -e "${fg_red} [SUSPECT!]${reset}"
			return 1
		else
			echo -e "${fg_green} [OK!]${reset}"
			return 0
		fi;
	else
		echo -e " [Not installed]"
		return
	fi
}

if [ $(which dpkg) ]; then
	echo " - APT based distro"
	echo -n "   - Checking for debsums..."
	if [ $(which debsums) ]; then
		echo -e "${fg_green} [FOUND]${reset}"
	else
		echo -e "${fg_yellow} [Missing]${reset}"
		echo "    - Installing debsums..."
		sudo apt-get install -yq debsums
	fi;
	
	echo ""
	echo "Beginning package integrity audit..."

	# These checking themselves could be a risk, we need to validate them somehow
	debchecker debsums
	debchecker dpkg
	# Important stuff (core stuff that is prone to rootkits
	debchecker coreutils
	debchecker mount
	debchecker openssh-client
	debchecker openssh-server
	debchecker linux-generic
	debchecker login
	debchecker apt
	debchecker bzip2
	debchecker gzip
	debchecker tar
	# Less important user applications
	debchecker apache
	debchecker php5
	debchecker php5-cgi
	debchecker php5-cli
	debchecker firefox
	debchecker gnupg
	debchecker gcc
	debchecker xorg
	debchecker vim
fi;

