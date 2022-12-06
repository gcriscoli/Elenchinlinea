#! /bin/bash

declare CURRENT_FIREWALL_STATUS='attivo'
declare PREFIX

[[ -z $(pgrep firewalld) ]] && PREFIX='dis'

CURRENT_FIREWALL_STATUS=${PREFIX}${CURRENT_FIREWALL_STATUS}

declare -a OPTIONS=('Sì' 'No' 'Salta' 'Esci')
declare OPTION

printf "%s ${RED}${BOLD}%${GAP}s${NORMAL}\n" "Lo stato attuale del firewall di sistema è:" "${CURRENT_FIREWALL_STATUS}"
printf "\n%s\n" "Modificare lo stato del firewall?"

select OPTION in ${OPTIONS[@]};
do
	case $OPTION in
		Sì)
			if [[ $CURRENT_FIREWALL_STATUS == 'attivo' ]];
			then
				systemctl stop firewalld && printf "\n%s\n" "Fatto!"
			else
				systemctl start firewalld && printf "\n%s\n" "Fatto!"
			fi
		;;
		No|Salta)
		;;
		Esci)
			exit 1
		;;
	esac
	break
done

printf "\n%s\n" "Modificare ${RED}${BOLD}permanentemente${NORMAL} lo stato del firewall?"

select OPTION in ${OPTIONS[@]};
do
	case $OPTION in
		Sì)
			if [[ $CURRENT_FIREWALL_STATUS == 'attivo' ]];
			then
				systemctl disable firewalld && printf "\n%s\n" "Fatto!"
			else
				systemctl enable firewalld && printf "\n%s\n" "Fatto!"
			fi
		;;
		No|Salta)
		;;
		Esci)
			exit 1
		;;
	esac
	break
done
