#! /bin/bash

declare CHRONY_CONF_FILE='/etc/chrony.conf'

declare CURRENT_CHRONY_CONFIG=$(grep -E --regexp="^${NTP_CONFIG_LINE_REGEXP}" ${CHRONY_CONF_FILE} | grep -Eo --regexp="${NTP_SERVER_ADDRESS_REGEXP}")

declare -a TIME_SERVERS
declare -i TIME_SERVER_NR
declare -i INDEX=1

declare NEW_TIME_SERVER_TYPE
declare NEW_TIME_SERVER_ADDRESS

declare OPTIONS=('Sì' 'No' 'Salta' 'Interrompi' 'Esci')

# Configurazione del server del tempo
printf "%s\n" "L'orario di sistema è configurato come segue:"
timedatectl
printf "\n"

readarray -t TIME_SERVERS <<< $CURRENT_CHRONY_CONFIG
TIME_SERVERS_NR=${#TIME_SERVERS[@]}
printf "%s\n" "La configurazione attuale consta di ${TIME_SERVERS_NR} server del tempo:"

for TIME_SERVER in ${TIME_SERVERS[@]};
do
	printf "%-2s%${GAP}s\n" "-" "${TIME_SERVER}"
done
printf "\n"

printf "%s\n" "Modificare la configurazione attuale dei server del tempo?"
select OPTION in ${OPTIONS[@]};
do
	case ${OPTION} in
	Sì)
		read -p "Inserire di seguito la nuova riga di configurazione del server del tempo nella forma (server|pool) (<IndirizzoIPv4>|<FQDN>) " NEW_TIME_SERVER_TYPE NEW_TIME_SERVER_ADDRESS
		printf "\n%s\n" "${BOLD}Sostituire${NORMAL} o ${BOLD}Integrare${NORMAL} la lista dei server già definiti?"
		select OPTION in "Sostituire" "Integrare";
		do
			case $OPTION in
				Sostituire)
					printf "%s\n" "La configurazione attuale consta di ${TIME_SERVERS_NR} server del tempo:"
					if [[ $TIME_SERVERS_NR > 1 ]]
					then
						INDEX=1
						while [[ $INDEX < $TIME_SERVERS_NR ]];
						do
							sed -Ei".old.${INDEX}" "/${NTP_TYPE_REGEXP} ${TIME_SERVERS[${INDEX}]} iburst/ d" ${CHRONY_CONF_FILE} && printf "%s\n" "Rimosso il server ${TIME_SERVERS[${INDEX}]}"
							INDEX+=1
						done
					fi
					sed -Ei".old.0" "s/${NTP_TYPE_REGEXP} ${TIME_SERVERS[0]} iburst/$NEW_TIME_SERVER_TYPE $NEW_TIME_SERVER_ADDRESS iburst/" ${CHRONY_CONF_FILE} && printf "%s\n" "Fatto!"
				;;

				Integrare)
					SED_STRING="/^${NTP_TYPE_REGEXP} ${TIME_SERVERS[0]} iburst$/ i\\${NEW_TIME_SERVER_TYPE} ${NEW_TIME_SERVER_ADDRESS} iburst"
					([[ -z $(grep "'${NEW_TIME_SERVER_TYPE} ${NEW_TIME_SERVER_ADDRESS} iburst'" $CHRONY_CONF_FILE) ]] && sed -E --in-place='.old' "${SED_STRING}" ${CHRONY_CONF_FILE}) && printf "%s\n" "Fatto!" || printf "%s\n" "Il server del tempo indicato è già presente nella lista dei server del tempo."
				;;
			esac
			break
		done
	;;

	No|Salta|Interrompi)
		break
	;;

	Esci)
		exit 1
	;;
	esac
	printf "%s\n" "Modificare ulteriormente la configurazione attuale dei server del tempo?"
done

source "${OS_SETUP_SOURCES_DIR}timezone_setup.sh"

source "${OS_SETUP_SOURCES_DIR}synchro_setup.sh"
