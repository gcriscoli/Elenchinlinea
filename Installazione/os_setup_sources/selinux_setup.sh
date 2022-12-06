#! /bin/bash

# Configurazione di SELinux

#declare BOLD=$(tput bold)
#declare RED=$(tput setaf 1)
#declare NORMAL=$(tput sgr0)

declare SELINUX_CONFIG_FILE='/etc/selinux/config'

declare SELINUX_MODES_REGEXP='(enforcing|permissive|disabled)$'
declare SELINUX_SETUP_REGEXP="^SELINUX=${SELINUX_MODES_REGEXP}"
declare CURRENT_SELINUX_MODE=$(grep -E --regexp=${SELINUX_SETUP_REGEXP} ${SELINUX_CONFIG_FILE} | grep -Eo --regexp=${SELINUX_MODES_REGEXP})
declare -a SELINUX_MODES=('enforcing' 'permissive' 'disabled')
declare NEW_SELINUX_MODE

declare -a OPTIONS=('Sì' 'No' 'Salta' 'Esci')
declare OPTION

[[ -f ${SELINUX_CONFIG_FILE} ]] || exit 1

printf "%s ${RED}${BOLD}%${GAP}s${NORMAL}\n" "SELinux è attualmente configurato in modalità" "${CURRENT_SELINUX_MODE}"
printf "\n%s\n" "Modificare la modalità operativa di SELinux?"

select OPTION in ${OPTIONS[@]};
do
	case $OPTION in
	Sì)
		printf "\n%s\n" "Scegliere la ${RED}${BRIGHT}nuova modalità operativa${NORMAL} di SELinux tra"
		select NEW_SELINUX_MODE in ${SELINUX_MODES[@]};
		do
			printf "\n${BOLD}${RED}%s${NORMAL}\n" "ATTENZIONE!"
			printf "%s ${BOLD}${RED}%s${NORMAL} " "In modalità" $NEW_SELINUX_MODE
			case $NEW_SELINUX_MODE in
				enforcing)
					printf "%s\n" "alcune modifiche al sistema potrebbero essere impossibili, così come l'esercizio di servizi che apportano modifiche al sistema."
				;;
				permissive)
					printf "%s\n" "tutte le modifiche al sistema sono possibili, così come l'esercizio di servizi che apportano modifiche al sistema, ma le azioni vengono tracciate come 'potenzialmente dannose'."
				;;
				disabled)
					printf "%s\n" "tutte le modifiche al sistema sono possibili, così come l'esercizio di servizi che apportano modifiche al sistema, costituendo una possibile vulnerabilità per il sistema."
				;;
			esac
			break
		done

		printf "\n%s\n" "Procedere comunque?"
		declare OPTIONS=('Sì' 'No')
		declare OPTION
		select OPTION in ${OPTIONS[@]};
		do
			[[ $OPTION == 'No' ]] && NEW_SELINUX_MODE=${CURRENT_SELINUX_MODE}
			break
		done

		# Sostituzione della riga di confiurazione attuale con le nuove imposazioni nel file di configurazione di SELinux
		sed -Ei'.old' "s/${SELINUX_SETUP_REGEXP}/SELINUX=${NEW_SELINUX_MODE}/" ${SELINUX_CONFIG_FILE} && printf "%s\n" "Fatto!"

		break
	;;

	No|Salta)
		break
	;;

	Esci)
		exit 0
	;;
	esac
done

