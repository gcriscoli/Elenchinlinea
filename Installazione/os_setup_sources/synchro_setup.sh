#! /bin/bash

# Abilitazione/Disabilitazione della sincronizzazione automatica
declare CURRENT_NTP_SYNCHRO=$(timedatectl | grep -E --regexp='NTP service: (in)?active' | grep -Eo --regexp='(in)?active')

declare NEW_NTP_SYNCHRO

if [[ $CURRENT_NTP_SYNCHRO == 'active' ]];
then
	CURRENT_NTP_SYNCHRO='abilitata'
	NEW_NTP_SYNCHRO=0
else
	CURRENT_NTP_SYNCHRO='disabilitata'
	NEW_NTP_SYNCHRO=1
fi

declare OPTIONS=('Sì' 'No' 'Salta' 'Interrompi' 'Esci')

printf "%s ${RED}${BOLD}%${GAP}s${NORMAL}\n" "Attualmente la sincronizzazione dell'orologio di sistema è" "${CURRENT_NTP_SYNCHRO}"
printf "%s\n" "Modificare l'impostazione?"
select OPTION in ${OPTIONS[@]};
do
	case $OPTION in
	Sì)
		timedatectl set-ntp $NEW_NTP_SYNCHRO && printf "%s\n" "Fatto!"
	;;
	No|Salta|Interrompi)
	;;
	Esci)
		exit 1
	;;
	esac
	break
done
