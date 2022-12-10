#! /bin/bash -x

function set_new_proxy_settings {

	local CONFIGURATION_ITEM=$1

	printf "%s\n" "Modificare la configurazione attuale?"
	select CHANGE in 'Sì' 'No';
	do
		case $CHANGE in

		No)
		;;

		Sì)
			## Per ogni configuration item (dnf, yum, wget, .bashrc, rhsm, ...)
			#for CONFIGURATION_ITEM in ${PROXY_CONFIGURATION_ITEMS[@]};
			#do
				# Se ne esiste il file di configurazione come previsto
				if [[ -f ${PROXY_FILES[$CONFIGURATION_ITEM]} ]];
				then
					# Allora commenta qualunque configurazione di proxy eventualmente già presente
					sed -Ei "s/${SED_PROXY_REGEXPS[${CONFIGURATION_ITEM}]}/${COMMENT}\1/" ${PROXY_FILES[${CONFIGURATION_ITEM}]}
					# Inoltre, aggiungi le righe di configurazione così come previste per lo specifico file di configurazione
					case $CONFIGURATION_ITEM in
						DNF|YUM)
							# Nel caso di YUM e di DNF, la riga di configurazione per il proxy deve essere aggiunta nella sezione [main] del file di configurazione
							sed -Ei "/\[main\]/a proxy=${PROXY_PROTOCOL}://${PROXY_SERVER}:${PROXY_PORT}/" ${PROXY_FILES[${CONFIGURATION_ITEM}]}
							;;

						WGET)
							# Nel caso di WGET deve essere creata una riga di configurazione specifica per ogni protocollo (http, https e ftp)
							# Non è definita una posizione specifica per la riga di configurazione, quindi è sufficiente aggiungerle in fondo al file di configurazione
							local -a CONFIGURATION_LINES=('http' 'https' 'ftp')
							for CONFIGURATION_LINE in ${CONFIGURATION_LINES[@]};
							do
								printf "%s\n" "${CONFIGURATION_LINE}_proxy = ${PROXY_PROTOCOL}://${PROXY_SERVER}:${PROXY_PORT}/" >> ${PROXY_FILES[${CONFIGURATION_ITEM}]}
							done
							unset CONFIGURATION_LINES
							# Infine, indipendentemente da quale sia la sua impostazione corrente, l'uso del proxy deve essere abilitato
							sed -Ei "s/${COMMENT_REGEXP}?(use_proxy = o)(n|ff)/\2n/" ${PROXY_FILES[${CONFIGURATION_ITEM}]}
							;;

						Utente)
							# Le impostazioni per il singolo utente vengono memorizzate in .bashrc
							# Anche in questo caso è necessaria una riga di configurazione per ogni protocollo, tra http, https, ftp e telnet
							# Anche in questo caso, la posizione non è rilevante
							local -a CONFIGURATION_LINES=('http' 'https' 'ftp' 'telnet')
							for CONFIGURATION_LINE in ${CONFIGURATION_LINES[@]};
							do
								printf "%s\n" "export ${CONFIGURATION_LINE}_proxy=${PROXY_PROTOCOL}://${PROXY_SERVER}:${PROXY_PORT}/" >> ${PROXY_FILES[${CONFIGURATION_ITEM}]}
							done
							unset CONFIGURATION_LINES
							;;

						Environment)
							# Le impostazioni di ambiente, comuni a tutti gli utenti del sistema, sono identiche a quelle per i singoli utenti, con l'eccezione che le variabili non devono essere esportate
							local -a CONFIGURATION_LINES=('http' 'https' 'ftp' 'telnet')
							for CONFIGURATION_LINE in ${CONFIGURATION_LINES[@]};
							do
								printf "%s\n" "${CONFIGURATION_LINE}_proxy=${PROXY_PROTOCOL}://${PROXY_SERVER}:${PROXY_PORT}/" >> ${PROXY_FILES[${CONFIGURATION_ITEM}]}
							done
							unset CONFIGURATION_LINES
							;;

						RHSM)
							# Il file di configurazione per RHSM consta di tre righe di congiurazione separate:
							# -	una per il server
							# -	una per la porta
							# -	una per il protocollo di connessione
							printf "%s\n" "proxy_hostname = ${PROXY_SERVER}" >> ${PROXY_FILES[$CONFIGURATION_ITEM]}
							printf "%s\n" "proxy_port = ${PROXY_PORT}" >> ${PROXY_FILES[$CONFIGURATION_ITEM]}
							printf "%s\n" "proxy_scheme = ${PROXY_PROTOCOL}" >> ${PROXY_FILES[$CONFIGURATION_ITEM]}
						;;
					esac
				fi
				PROXY_SET[${CONFIGURATION_ITEM}]='SET'
			#done
		;;
		esac
		break
	done
}

function get_current_proxy_settings {

	# Per ogni configuration item (dnf, yum, wget, .bashrc, rhsm, ...)
	for CONFIGURATION_ITEM in ${PROXY_CONFIGURATION_ITEMS[@]};
	do
		# Se ne esiste il file di configurazione come previsto
		if [[ -f ${PROXY_FILES[${CONFIGURATION_ITEM}]} ]];
		then
			printf "\n%s\n" "Configurazione attuale del server proxy per ${BOLD}${CONFIGURATION_ITEM}${NORMAL}:"

			# La variabile d'ambiente IFS (Internal Field Separator) definisce il carattere (o la sequenza di caratteri) utilizzata da BASH per riconoscere il limite tra due campi di uno stesso array
			# Il separatore di default è il carattere spazio
			# Per poter identificare come voci di un array stringhe contenenti spazi ma separate (come in questo caso) dal carattere di 'a capo' (\n), bisogna ridefinire la variabile IFS
			local DEFAULT_IFS=${IFS}
			IFS=$'\n'
			# Ora il risultato di grep può essere caricato correttamente in un array di cui ogni elemento contenga l'intera riga prodotta da grep, anche se questa dovesse contenere spazi
			readarray CURRENT_PROXY_SETTINGS <<< $(grep -E --regexp="${GREP_PROXY_REGEXPS[${CONFIGURATION_ITEM}]}" ${PROXY_FILES[${CONFIGURATION_ITEM}]})

			# L'output di grep può essere anche nullo, nel qual caso il numero di elementi dell'array dei risultati sarebbe 0
			# In tal caso, si può assumere che nessun proxy sia stato definito per lo specifico configuration item
			echo "CURRENT_PROXY_SETTINGS[@]: ${CURRENT_PROXY_SETTINGS[@]}; #CURRENT_PROXY_SETTINGS: ${#CURRENT_PROXY_SETTINGS}; #CURRENT_PROXY_SETTINGS[@]: ${#CURRENT_PROXY_SETTINGS[@]}"
			if [[ ${#CURRENT_PROXY_SETTINGS[@]} == 0 ]];
			then
				printf "\t${RED}${BOLD}%s${NORMAL}" "NON DEFINITA"
			# Diversamente, un proxy deve essere stato definito, quindi se ne può stampare la configurazione corrente
			else
				for SETTINGS in ${CURRENT_PROXY_SETTINGS[@]};
				do
					printf "\n%-2s${RED}${BOLD}%${GAP}s${NORMAL}" "-" "${SETTINGS}"
				done
				printf "\n\n"
			fi
			
			# Terminata l'esigenza, IFS può essere riportata al suo valore originale
			IFS=${DEFAULT_IFS}
			unset DEFAULT_IFS

			# A questo punto è possibile definire una nuova configurazione
			set_new_proxy_settings ${CONFIGURATION_ITEM}
		fi
	done
}

function unset_current_proxy_settings {
	# Nell'ipotesi che l'utente decida di non effettuare connessioni ad Internet tramite proxy, i proxy eventualmente definiti devono essere disabilitati per tutti i servizi, individualmente

	# Per ogni configuration item
	for CONFIGURATION_ITEM in ${PROXY_CONFIGURATION_ITEMS[@]};
	do
		# Se ne esiste il file di configurazione
		if [[ -f ${PROXY_FILES[${CONFIGURATION_ITEM}]} ]];
		then
			# Allora è necessario confermare con l'utente che il servizio proxy debba essere disabilitato par lo specifico configuration item
			printf "\n%s ${RED}${BOLD}%s${NORMAL}%s\n" "Disabilitare la connessione tramite proxy per" "${CONFIGURATION_ITEM}" "?"
			select DISABLE_PROXY in "Sì" "No";
			do
				case $DISABLE_PROXY in
					Sì)
						# In caso di conferma dell'utente, le eventuali righe di configurazione del proxy così come definite da ciascun configuration item vengono commentate
						sed -Ei'.old' "s/${SED_PROXY_REGEXPS[${CONFIGURATION_ITEM}]}/${COMMENT}\1/" ${PROXY_FILES[${CONFIGURATION_ITEM}]}
						# Inoltre, nel caso di WGET, è necessario disabilitare esplicitamente l'uso del proxy
						sed -Ei "s/^${COMMENT_REGEXP}?(use_proxy = o)(n|ff)/\2ff/" ${PROXY_FILES[${CONFIGURATION_ITEM}]}
					;;

					No)
					;;
					esac
					break
			done
		fi
	done
}

function get_new_proxy_settings {

	# Le impostazioni relative al proxy vengono conservate in un file di ambiente che viene caricato ad ogni riavvio
	# Se tale file non esiste, deve essere creato con i privilegi corretti
	[[ -f ${PROXY_FILES[Environment]} ]] || (touch ${PROXY_FILES[Environment]} && chown root:root ${PROXY_FILES[Environment]} && chmod +x ${PROXY_FILES[Environment]})

	printf "%s\n" "Scegliere il ${BOLD}protocollo di connessione${NORMAL} al server proxy"
	select PROXY_PROTOCOL in ${PROXY_PROTOCOLS[@]};
	do
		break
	done
	# Il file d'ambiente viene sovrascritto ogni volta che si decide per la definizione di un nuovo proxy di riferimento, annullando tutte le configurazioni d'ambiente precedenti
	echo "PROXY_PROTOCOL=$PROXY_PROTOCOL" > ${PROXY_FILES[Environment]}

	read -p "Inserire l'${BOLD}indirizzo IPv4${NORMAL} o l'${BOLD}FQDN${NORMAL} del server proxy di riferimento: " PROXY_SERVER

	[[ $PROXY_SERVER =~ ${PROXY_SERVER_ADDRESS_REGEXP} ]] || PROXY_SERVER=${DEFAULT_PROXY_SERVER}
	echo "PROXY_SERVER=$PROXY_SERVER" >> ${PROXY_FILES[Environment]}

	read -p "Inserire la ${BOLD}porta${NORMAL} del server proxy di riferimento: " PROXY_PORT

	[[ $PROXY_PORT =~ ${PORT_REGEXP} ]] || PROXY_PORT=${DEFAULT_PROXY_PORT}
	echo "PROXY_PORT=$PROXY_PORT" >> ${PROXY_FILES[Environment]}
}

printf "%s\n" "Utilizzare un ${BOLD}server proxy${NORMAL} per connettersi ad Internet?"

select DEFINE_NEW_PROXY in ${ACTIONS[@]};
do
	case $DEFINE_NEW_PROXY in
	Sì)
		get_new_proxy_settings
		get_current_proxy_settings
	;;

	No)
		unset_current_proxy_settings
	;;
	
	Salta)
	;;

	Esci)
		echo "Uscita"
		exit 1
	;;
	esac
	break
done
