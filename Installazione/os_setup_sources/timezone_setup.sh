#! /bin/bash

# Modifica della timezone
declare CONTINENT_COUNTRY_REGEXP='[a-zA-Z_]+'
declare TIMEZONE_REGEXP="(UTC|${CONTINENT_COUNTRY_REGEXP}/${CONTINENT_COUNTRY_REGEXP})"

declare CURRENT_TIMEZONE=$(timedatectl | grep -E --regexp="Time zone: ${TIMEZONE_REGEXP}" | grep -Eo --regexp="${TIMEZONE_REGEXP}")
declare DEAFULT_TIMEZONE='Europe/Rome'

declare OPTIONS=('Sì' 'No' 'Salta' 'Interrompi' 'Esci')

		printf "%s ${RED}${BOLD}%${GAP}s${NORMAL}\n" "Il fuso orario del sistema è:" "${CURRENT_TIMEZONE}"
		printf "%s\n" "Modificare il fuso orario di riferimento?"
		select OPTION in ${OPTIONS[@]};
		do
			case $OPTION in
			Sì)
				read -p "Inserire di seguito il nuovo fuso orario di riferimento nella forma (<Continent/City>|UTC) (${BRIGHT}Invio${NORMAL} per utilizzare i valori di default Europe/Rome): " NEW_TIMEZONE
				[[ -z $NEW_TIMEZONE ]] && NEW_TIMEZONE=$DEFAULT_TIMEZONE
				[[ $NEW_TIMEZONE =~ ${TIMEZONE_REGEXP} ]] && timedatectl set-timezone ${NEW_TIMEZONE} && printf "%s\n" "Fatto!"
			;;
			No|Salta|Interrompi)
			;;
			Esci)
				exit 1
			;;
			esac
			break
		done
