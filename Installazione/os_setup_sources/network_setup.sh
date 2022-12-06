#! /bin/bash

# Forzatura del colore standard, indipendentemente dalle impostazioni preesistenti
printf "%s\n" "$(tput sgr0)"

# Pulizia dello schermo dai messaggi precedenti
tput clear

# Definizione delle funzioni
function get_current_configuration()
{
	local NW_IFACE_CARD=$1

	local IPV4_PARAM=$2
	local IPV4_PARAM_REGEXP=$3
	local IPV4_PARAM_ITA
	local IPV4_PARAM_SEPARATOR=','

	local -a CURRENT_CONFIGURATION

	case $IPV4_PARAM in
		addresses)
			IPV4_PARAM_ITA='indirizzi'
			IPV4_PARAM_SEPARATOR=', '
		;;
		dns)
			IPV4_PARAM_ITA='server DNS'
		;;
		dns-search)
			IPV4_PARAM_ITA='domini di ricerca'
		;;
	esac

	printf "\n%s\n" "L'interfaccia di rete ${NW_IFACE_CARD} è attualmente configurata con i seguenti ${IPV4_PARAM_ITA} IPv4:"

	readarray -d${IPV4_PARAM_SEPARATOR} -t CURRENT_CONFIGURATION <<< $(nmcli connection show ${NW_IFACE_CARD} | grep -E 'ipv4.'$IPV4_PARAM':' | grep -Eo --regexp=${IPV4_PARAM_REGEXP})

	for SETTING in ${CURRENT_CONFIGURATION[@]};
	do
		printf "%s %s\n" "-" "${SETTING}"
	done

	printf "\n"
}

function network_manual_setup()
{

	local -a IPV4_PARAMS_ARRAY=('addresses' \
	   'dns' \
	   'dns-search' \
	)

	local -a IPV4_PARAMS_ITA_ARRAY=('indirizzi IPv4 completi di maschera di sottorete' \
		   'server DNS IPv4' \
		   'domini di ricerca' \
		   )

	local -a IPV4_PARAM_REGEXPS_ARRAY=(${IPV4_COMPLETE_ADDRESS_LIST_REGEXP} \
			   ${IPV4_ADDRESS_LIST_REGEXP} \
			   #${IPV4_SEARCH_DOMAIN_LIST_REGEXP}
			   "(\w+(\.\w+)*)(,(\w+(\.\w+)*))*$" \
			   )

	local -a IPV4_SINGLE_SETTING_REGEXPS_ARRAY=(${IPV4_COMPLETE_ADDRESS_REGEXP} \
					   ${IPV4_ADDRESS_REGEXP} \
					   ${IPV4_SEARCH_DOMAIN_REGEXP} \
					   )

	local N_IFC=$1

	local -a ACTIONS=('Aggiungi' \
	   'Rimuovi' \
	   'Sostituisci'
	   'Salta' \
	   'Avanti' \
	   'Esci' \
   )

	local IPV4_PARAM_INDEX

	for IPV4_PARAM_INDEX in ${!IPV4_PARAMS_ARRAY[@]};
	do
		printf "\n$(tput setaf 1)$(tput bold)%s$(tput sgr0)\n" "${IPV4_PARAMS_ITA_ARRAY[$IPV4_PARAM_INDEX]}"
		printf "\n%s\n" "È ora possibile"
		printf "%-2s$(tput bold)%s$(tput sgr0) %s $(tput bold)%s$(tput sgr0) %s $(tput bold)%s$(tput sgr0)\n" "-" "Aggiungere" "uno o più" "${IPV4_PARAMS_ITA_ARRAY[$IPV4_PARAM_INDEX]}" "a quelli già configurati sull'interfaccia" "${N_IFC}"
		printf "%-2s$(tput bold)%s$(tput sgr0) %s $(tput bold)%s$(tput sgr0) %s $(tput bold)%s$(tput sgr0)\n" "-" "Rimuovere" "uno o più" "${IPV4_PARAMS_ITA_ARRAY[$IPV4_PARAM_INDEX]}" "da quelli già configurati sull'interfaccia" "${N_IFC}"
		printf "%-2s$(tput bold)%s$(tput sgr0) %s $(tput bold)%s$(tput sgr0) %s $(tput bold)%s$(tput sgr0)\n" "-" "Sostituire" "tutti i/gli" "${IPV4_PARAMS_ITA_ARRAY[$IPV4_PARAM_INDEX]}" "già configurati sull'interfaccia" "${N_IFC}"
		printf "%-2s$(tput bold)%s$(tput sgr0) %s\n" "-" "Saltare" "questo passaggio"
		printf "%-2s$(tput bold)%s$(tput sgr0) %s\n" "-" "Uscire" "dalla procedura di configurazione iniziale"

		get_current_configuration ${N_IFC} ${IPV4_PARAMS_ARRAY[$IPV4_PARAM_INDEX]} ${IPV4_PARAM_REGEXPS_ARRAY[$IPV4_PARAM_INDEX]}

		printf "%s\n" "Scegliere l'azione che si intende intraprendere"
		select ACTION in ${ACTIONS[@]};
		do
			case ${ACTION} in
				Aggiungi)
					printf "%s $(tput bold)%s$(tput sgr0) %s $(tput bold)%s$(tput sgr0):\n" "Inserire di seguito i/gli" "${IPV4_PARAMS_ITA_ARRAY[$IPV4_PARAM_INDEX]}" "da aggiungere, separandoli" "con uno spazio"
					read NEW_BLANK_SEPARATED_SETTINGS_LIST
					readarray -d' ' NEW_SETTINGS <<< ${NEW_BLANK_SEPARATED_SETTINGS_LIST}

					for NEW_SETTING in ${NEW_SETTINGS[@]};
					do
						[[ ${NEW_SETTING} =~ ${IPV4_SINGLE_SETTING_REGEXPS_ARRAY[$IPV4_PARAM_INDEX]} ]] && nmcli connection modify ${N_IFC} +ipv4.${IPV4_PARAMS_ARRAY[$IPV4_PARAM_INDEX]} ${NEW_SETTING}
					done

					get_current_configuration ${N_IFC} ${IPV4_PARAMS_ARRAY[$IPV4_PARAM_INDEX]} ${IPV4_PARAM_REGEXPS_ARRAY[$IPV4_PARAM_INDEX]}

					printf "%s\n" "Premere invio per continuare..."
					#break
				;;

				Rimuovi)
					printf "%s $(tput bold)%s$(tput sgr0) %s $(tput bold)%s$(tput sgr0):\n" "Inserire di seguito i/gli" "${IPV4_PARAMS_ITA_ARRAY[$IPV4_PARAM_INDEX]}" "da rimuovere, separandoli" "con uno spazio"
					read NEW_BLANK_SEPARATED_SETTINGS_LIST
					readarray -d' ' NEW_SETTINGS <<< ${NEW_BLANK_SEPARATED_SETTINGS_LIST}

					for NEW_SETTING in ${NEW_SETTINGS[@]};
					do
						[[ ${NEW_SETTING} =~ ${IPV4_SINGLE_SETTING_REGEXPS_ARRAY[$IPV4_PARAM_INDEX]} ]] && nmcli connection modify ${N_IFC} -ipv4.${IPV4_PARAMS_ARRAY[$IPV4_PARAM_INDEX]} ${NEW_SETTING}
					done

					get_current_configuration ${N_IFC} ${IPV4_PARAMS_ARRAY[$IPV4_PARAM_INDEX]} ${IPV4_PARAM_REGEXPS_ARRAY[$IPV4_PARAM_INDEX]}

					printf "%s\n" "Premere invio per continuare..."
					#break
				;;

				Sostituisci)
					printf "%s $(tput bold)%s$(tput sgr0) %s $(tput bold)%s$(tput sgr0):\n" "Inserire di seguito i/gli" "${IPV4_PARAMS_ITA_ARRAY[$IPV4_PARAM_INDEX]}" "da impostare, separandoli" "con uno spazio"
					read NEW_BLANK_SEPARATED_SETTINGS_LIST
					readarray -d' ' NEW_SETTINGS <<< $NEW_BLANK_SEPARATED_SETTINGS_LIST

					nmcli connection modify $N_IFC ipv4.${IPV4_PARAMS_ARRAY[$IPV4_PARAM_INDEX]} ''
					for NEW_SETTING in ${NEW_SETTINGS[@]};
					do
						[[ ${NEW_SETTING} =~ ${IPV4_SINGLE_SETTING_REGEXPS_ARRAY[$IPV4_PARAM_INDEX]} ]] && nmcli connection modify $N_IFC +ipv4.${IPV4_PARAMS_ARRAY[$IPV4_PARAM_INDEX]} ${NEW_SETTING}
					done

					get_current_configuration ${N_IFC} ${IPV4_PARAMS_ARRAY[$IPV4_PARAM_INDEX]} ${IPV4_PARAM_REGEXPS_ARRAY[$IPV4_PARAM_INDEX]}

					printf "%s\n" "Premere invio per continuare..."
					#break
				;;

				Avanti|Salta)
					break
				;;

				Esci)
					exit 1
				;;
			esac
		done

	done
}

# Impostazione delle configurazioni di rete per ogni interfaccia disponibile
declare -a ALL_SYSTEM_NICS
readarray -d' ' ALL_SYSTEM_NICS <<< $(nmcli -t | grep -Eo --regexp='^\w{3,}:' | grep -Eo --regexp='\w+')

ALL_SYSTEM_NICS+='Salta Esci'

printf "\n$(tput setaf 1)$(tput bold)%s$(tput sgr0)\n\n" "Impostazione delle configurazioni di rete per ogni interfaccia disponibile."
printf "%s\n%s\n" "Nel sistema sono disponibili le seguenti interfacce di rete." "Scegliere quale si intende configurare:"

select NIC in ${ALL_SYSTEM_NICS[@]};
do
	if [[ $NIC == 'Salta' ]];
	then
		break
	elif [[ $NIC == 'Esci' ]];
	then
		exit 1
	else
		# Impostazione delle modalità di connessione
		printf "\n%s\n" "Scegliere la modalità di configurazione della rete:"
		
		select METHOD in "Automatica" "Manuale" "Salta" "Esci";
		do
			case $METHOD in
				Salta)
					break
					;;
				Esci)
					exit 1
					;;
				Automatica)
					nmcli connection modify $NIC ipv4.method auto ipv4.addresses '' ipv4.gateway '' ipv4.dns '' ipv4.dns-search ''
					break
					;;
				Manuale)
					network_manual_setup $NIC || exit 1

					# Impostazione del gateway
					printf "\n$(tput setaf 1)$(tput bold)%s$(tput sgr0)\n\n" "Impostazione del gateway"
					printf "%s$(tput setaf 1)$(tput bold)%20s$(tput sgr0)\n" "Il gateway attualmente configurato sull'interfaccia ${NIC} è:" "$(nmcli connection show ${NIC} | grep 'ipv4.gateway' | grep -Eo --regexp=${IPV4_ADDRESS_REGEXP})"
					printf "%s\n" "Sostituire il gateway attualmente definito? (s/n)"

					select WHAT_TO_DO_NEXT in "Sì" "No" "Salta" "Esci";
					do
						case $WHAT_TO_DO_NEXT in
							No|Salta)
								break
								;;
							Esci)
								exit 1;
								;;
							Sì)
								while [[ ! $NEW_GATEWAY =~ $IPV4_ADDRESS_REGEXP ]];
								do
									read -p "Inserire l'indirizzo IPv4 del nuovo gateway: " NEW_GATEWAY
								done;
								nmcli connection modify ${NIC} ipv4.gateway $NEW_GATEWAY
								;;
						esac
					done
				# Modifica del metodo di connessione
				nmcli connection modify $NIC ipv4.method manual
				break
				;;
				esac
		done
	fi

	# Riavvio della rete con le nuove impostazioni
	printf "\n$(tput setaf 1)$(tput bold)%s$(tput sgr0)\n" "Riavvio delle connessioni di rete"
	printf "%s\n" "Per rendere effettive le modifche apportate è necessario riavviare le connessioni di rete sull'interfaccia ${NIC}."
	printf "%s\n" "$(tput bold)Eventuali connessioni$(tput sgr0) in atto al momento del riavvio $(tput bold)saranno disconnesse$(tput sgr0):"
	printf "%s\n" "gli utenti dovranno iniziare una $(tput bold)nuova sessione con i nuovi indirizzi IPv4$(tput sgr0)"
	printf "%s\n" "Procedere al riavvio delle connessioni di rete?"
	select NETWORK_RESTART in "Sì" "No" "Salta" "Esci";
	do
		case ${NETWORK_RESTART} in
		Sì)
			nmcli connection down ${NIC}
			nmcli connection up ${NIC}
			break
		;;

		No|Salta)
			break
		;;

		Esci)
			exit 1
		;;

		esac
	done
	break

done
