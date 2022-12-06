#! /bin/bash

declare CURRENT_HOSTNAME=$(nmcli general hostname)
declare NEW_HOSTNAME

declare -a OPTIONS=('Sì' 'No' 'Salta' 'Esci')
declare OPTION

printf "%s ${RED}${BOLD}%${GAP}s${NORMAL}\n" "L'hostname attuale è:" "${CURRENT_HOSTNAME}"
printf "\n%s\n" "Modificare l'hostname?"

select OPTION in ${OPTIONS[@]};
do
	case $OPTION in
		Sì)
			read -p "Inserire il nuovo hostname: " NEW_HOSTNAME
			if [[ $NEW_HOSTNAME =~ $HOSTNAME_REGEXP ]];
			then
				if [[ $NEW_HOSTNAME == $CURRENT_HOSTNAME ]];
				then
					printf "%s\n" "Il nuovo ed il vecchio hostname coincidono."
				else
					nmcli general hostname $NEW_HOSTNAME && printf "%s\n" "Fatto!"
				fi
				break
			else
				printf "%s\n" "L'hostname fornito non risponde ai requisiti sintattici richiesti."
				printf "\n%s ${BOLD}%s${NORMAL} %s\n" "Premere" "INVIO" "per continuare."
			fi
		;;
		No|Salta)
			break
		;;
		Esci)
			exit 1
		;;
		
	esac
done
