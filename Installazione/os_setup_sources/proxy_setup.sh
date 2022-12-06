#! /bin/bash -x

# Definizione dei posti per cui può dover essere definito un proxy
declare -a PLACES=('DNF' \
				  'YUM' \
				  'WGET' \
				  'Utente' \
				  'Environment' \
				  'RHSM' \
				  )

# Ciascun elemento dell'array può assumere i due valori SET o UNSET, ad indicare che lo script di configurazione è stato eseguito anche se nessun proxy è definito o che un proxy è definito anche se lo script non è stato definito, oppure che NON è stato eseguito E nessun proxy è definito nel sistema.
declare -A PROXY_SET=(['DNF']='UNSET' \
					 ['YUM']='UNSET' \
					 ['WGET']='UNSET' \
					 ['Utente']='UNSET' \
					 ['Environment']='UNSET' \
					 ['RHSM']='UNSET' \
					 )

# Definizione delle posizioni dei files di configurazione corrispondenti a ciascun posto
declare -a FILES=(['DNF']='/etc/dnf/dnf.conf' \
				 ['YUM']='/etc/dnf/dnf.conf' \
				 ['WGET']='/etc/wgetrc' \
				 ['Utente']="/$(whoami)/.bashrc" \
				 ['Environment']='/etc/profile.d/proxy.sh' \
				 ['RHSM']='/etc/rhsm/rhsm.conf' \
)

declare PROXY_PROTOCOL
declare PROXY_SERVER
declare PROXY_PORT

function current_proxy_settings {

	[[! $# == 1 ]] && printf "\n%s\n" "Numero di parametri errato per la funzione $FUNC_NAME[0]" && exit 1

	local PLACE=$1

	if [[ -f ${FILE[${PLACE}]} ]];
	then
		printf "\n%s " "La configurazione attuale del proxy per DNF è:"

		case $PLACE in
		DNF|YUM)
			readarray CURRENT_PROXY_SETTINGS <<< $(grep -E --regexp='^proxy=http.*' ${FILE[$PLACE]})
		;;

		WGET)
			readarray CURRENT_PROXY_SETTINGS <<< $(grep -E --regexp='^((ht|f)tps?_proxy = (ht|f)tps?:\/\/).*' $FILE)
		;;

		Utente)
			readarray CURRENT_PROXY_SETTINGS <<< $(grep -E '^export ((ht|f)tps?|telnet)_proxy=https?://.*$' ${FILE[$PLACE]})
		;;

		Environment)
			readarray CURRENT_PROXY_SETTINGS <<< $(grep -E '^((ht|f)tps?|telnet)_proxy=https?://.*$' ${FILE[$PLACE]})
		;;

		RHSM)
			readarray CURRENT_PROXY_SETTINGS <<< $(grep -E '^proxy_hostname = [a-zA-Z0-9\.]+$' ${FILE[$PLACE]})
		;;
		esac

		[[ -z $CURRENT_PROXY_SETTINGS ]] || PROXY_SET[${PLACE}]='SET'
	fi
	
	for SETTINGS in ${CURRENT_PROXY_SETTINGS[@]};
	do
		printf "${RED}${BOLD}%s\t%s${NORMAL}\n" "-" "${SETTINGS}"
	done
	printf "\n"
}

function modify_proxy_settings {
	[[! $# == 1 ]] && printf "\n%s\n" "Numero di parametri errato per la funzione $FUNC_NAME[0]" && exit 1

	local PLACE=$1

	if [[ -f ${FILE[$PLACE]} ]];
	then
		case $PLACE in
		DNF|YUM)
			if [[ -z $(grep -E '^proxy=http.*' $FILE) ]];
			then
				sed -Ei'.old' '/\[main\]/a proxy=http://'${PROXY_SERVER}':'${PROXY_PORT}'/' ${FILE[$PLACE]}
			else
				sed -Ei'.old' "s/^(proxy=http:\/\/).*/\1${PROXY_SERVER}:${PROXY_PORT}\//" ${FILE[$PLACE]}
			fi
		;;

		WGET)
			if [[ -z $(grep -E --regexp='^((ht|f)tps?_proxy = (ht|f)tps?:\/\/).*' $FILE) ]];
			then
				sed -Ei'.old' 's/^((ht|f)tps?_proxy = (ht|f)tps?:\/\/).*/\1'${PROXY_SERVER}':'${PROXY_PORT}'\//' ${FILE[$PLACE]}
			else
				sed -Ei'.old' '/#http_proxy = /a http_proxy = http://'${PROXY_SERVER}'.'${PROXY_PORT} ${FILE[$PLACE]}
				sed -Ei'.old' '/#https_proxy = /a https_proxy = http://'${PROXY_SERVER}'.'${PROXY_PORT} ${FILE[$PLACE]}
				sed -Ei'.old' '/#ftp_proxy = /a ftp_proxy = http://'${PROXY_SERVER}'.'${PROXY_PORT} ${FILE[$PLACE]}
			fi
		;;

		Utente)
			if [[ -z $(grep -E '^export ((ht|f)tps?|telnet)_proxy=https?://.*$' ${FILE}) ]];
			then
				echo 'export http_proxy=http://'${PROXY_SERVER}':'${PROXY_PORT}'/' >> ${FILE[$PLACE]}
				echo 'export https_proxy=http://'${PROXY_SERVER}':'${PROXY_PORT}'/' >> ${FILE[$PLACE]}
				echo 'export ftp_proxy=http://'${PROXY_SERVER}':'${PROXY_PORT}'/' >> ${FILE[$PLACE]}
				echo 'export telnet_proxy=http://'${PROXY_SERVER}':'${PROXY_PORT}'/' >> ${FILE[$PLACE]}
			else
				sed -Ei'.old' "s/^#?(export ((ht|f)tps?|telnet)_proxy=https?://).*$/\1${PROXY_SERVER}:${PROXY_PORT}/" ${FILE[$PLACE]}
			fi
		;;

		Environment)
			if [[ -z $(grep -E '^((ht|f)tps?|telnet)_proxy=https?://.*$' ${FILE}) ]];
			then
				echo 'http_proxy=http://'${PROXY_SERVER}':'${PROXY_PORT}'/' >> ${FILE[$PLACE]}
				echo 'https_proxy=http://'${PROXY_SERVER}':'${PROXY_PORT}'/' >> ${FILE[$PLACE]}
				echo 'ftp_proxy=http://'${PROXY_SERVER}':'${PROXY_PORT}'/' >> ${FILE[$PLACE]}
				echo 'telnet_proxy=http://'${PROXY_SERVER}':'${PROXY_PORT}'/' >> ${FILE[$PLACE]}
			else
				sed -Ei'.old' "s/^(((ht|f)tps?|telnet)_proxy=https?://).*$/\1${PROXY_SERVER}:${PROXY_PORT}/" ${FILE[$PLACE]}
			fi
		;;

		RHSM)
			if [[ -z $(grep -E '^proxy_hostname = [a-zA-Z0-9\.]+$' ${FILE}) ]];
			then
				sed -Ei'.old' "s/^(proxy_hostname = ).+$/\1${PROXY_SERVER}/" ${FILE[$PLACE]}
				sed -Ei'.old' "s/^(proxy_scheme = ).+$/\1${PROXY_PROTOCOL}/" ${FILE[$PLACE]}
				sed -Ei'.old' "s/^(proxy_port = ).+$/\1${PROXY_PORT}/" ${FILE[$PLACE]}
			fi
		;;
		esac

		PROXY_SET[${PLACE}]='SET'
	fi
}

function define_new_proxy {
	[[ ! -f /etc/profile.d/proxy_setup.sh ]] && touch /etc/profile.d/proxy_setup.sh

	printf "%s\n" "Scegliere il ${BOLD}protocollo di connessione${NORMAL} al server proxy"
	select PROXY_PROTOCOL in ${PROXY_PROTOCOLS[@]};
	do
		break
	done
	echo "PROXY_PROTOCOL=$PROXY_PROTOCOL" > /etc/profile.d/proxy_setup.sh

	read -p "Inserire l'${BOLD}indirizzo IPv4${NORMAL} o l'${BOLD}FQDN${NORMAL} del server proxy di riferimento: " PROXY_SERVER

	[[ $PROXY_SERVER =~ ${PROXY_SERVER_ADDRESS_REGEXP} ]] || PROXY_SERVER=${DEFAULT_PROXY_SERVER}
	echo "PROXY_SERVER=$PROXY_SERVER" >> /etc/profile.d/proxy_setup.sh

	read -p "Inserire la ${BOLD}porta${NORMAL} del server proxy di riferimento: " PROXY_PORT

	[[ $PROXY_PORT =~ ${PORT_REGEXP} ]] || PROXY_PORT=${DEFAULT_PROXY_PORT}
	echo "PROXY_PORT=$PROXY_PORT" >> /etc/profile.d/proxy_setup.sh
}

printf "\n${RED}${BOLD}%s${NORMAL}\n\n" "Impostazioni di connessione ad Internet"
printf "%s\n" "Utilizzare un ${BOLD}server proxy${NORMAL} per connettersi ad Internet?"

select DEFINE_NEW_PROXY in ${ACTIONS[@]};
do
	case $DEFINE_NEW_PROXY in
	Sì)
		define_new_proxy

		for PLACE in ${PLACES[@]};
		do
			printf "\n%s\n" "Configurazione del server proxy per ${BOLD}${PLACE}${NORMAL}"

			current_proxy_settings $PLACE
			
			printf "%s\n" "Modificare la configurazione attuale?"
			select CHANGE in 'Sì' 'No' 'Salta' 'Esci';
			do
				case $CHANGE in
				Sì)
					modify_proxy_settings $PLACE
				;;

				No|Salta)
				;;

				Esci)
					exit 1
				;;
				esac
				
				break
			done
		done

		break
	;;

	No)
		for PLACE in ${PLACES[@]};
		do
			case ${PLACE} in
			'WGET'|'YUM')
				SED_STRING='^((ht|f)tps?_proxy = (ht|f)tps?:\/\/.*)$'
			;;
			'DNF')
				SED_STRING='^(proxy=https?.*)$'
			;;
			'Utente'|'Environment')
				SED_STRING='^((export )?((ht|f)tp|telnet)_proxy=https?.*)$'
			;;
			'RHSM')
				SED_STRING='^(proxy_(hostname|scheme|port) = .*)$'
			;;
			esac
			[[ -f ${FILES[$PLACE]} ]] && sed -Ei'.old' "s/${SED_STRING}/${COMMENT}\1/" ${FILES[$PLACE]}
			PROXY_SET[${PLACE}]='UNSET'
		done
		break
	;;
	
	Salta)
	;;

	Esci)
		echo "Uscita"
		exit 1
	;;
	esac
done
