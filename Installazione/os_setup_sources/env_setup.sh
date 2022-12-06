#! /bin/bash

# Definizione del prompt per le istruzioni select do ... done
PS3='-> '

# Definizione delle variabili di abbellimento del testo
declare -r UNDERLINE=$(tput smul)
declare -r END_UNDERLINE=$(tput rmul)
declare -r BOLD=$(tput bold)
declare -r BLINKING=$(tput blink)
declare -r REVERSE=$(tput rev)

declare -r NORMAL=$(tput sgr0)

declare -r BLACK=$(tput setaf 0)
declare -r RED=$(tput setaf 1)
declare -r GREEN=$(tput setaf 2)
declare -r YELLOW=$(tput setaf 3)
declare -r BLUE=$(tput setaf 4)
declare -r MAGENTA=$(tput setaf 5)
declare -r CYAN=$(tput setaf 6)
declare -r WHITE=$(tput setaf 7)
declare -r DEFAULT=$(tput setaf 9)

# Definizione delle distribuzioni supportate e delle relative espressioni regolari
declare -a DISTROS=("Fedora" "RHEL" "CEntOS" "OpenSuSE")
declare OS_RELEASE_FILE='/etc/os-release'

declare -r SUPPORTED_OS_NAMES_REGEXP="((Fedora|Red Hat Enterprise|CentOS) Linux|openSUSE (Leap|Tumbleweed))"
declare -r VERSION_IDS_REGEXP="([0-9]+\.)*[0-9]+"

# Verifica che la release corrente sia supportata dallo script e conseguente inizializzazione delle variabili descrittive della release in uso o uscita dallo script con un codice di errore
if [[ -f ${OS_RELEASE_FILE} ]];
then
	declare -r OS_NAME=$(grep -E --regexp='^NAME="'$SUPPORTED_OS_NAMES_REGEXP'"$' /etc/os-release | grep -Eo --regexp=$SUPPORTED_OS_NAMES_REGEXP)
	declare -r OS_VERSION=$(grep -E --regexp='VERSION_ID="'$VERSION_IDS_REGEXP'"' /etc/os-release | grep -Eo --regexp='')};
else
	printf "%s\n" "La presente distribuzione non è supportata da questo script: tutte le configurazioni dovranno essere fatte a mano."
	exit 1
fi

# Definizione dei percorsi di installazione definita dello script di configurazione e delle relative sorgenti
declare OS_SETUP_SCRIPT_DIR='/usr/bin'
declare OS_SETUP_SCRIPT=${OS_SETUP_SCRIPT_DIR}"/os_setup.sh"
declare OS_SETUP_SOURCES_DIR="${OS_SETUP_SCRIPT_DIR}/os_setup_sources/"

# Verifica dell'esistenza della direcotry di installazione degli script di configurazione o creazione della stessa con i privilegi corretti
[[ -d ${OS_SETUP_SOURCES_SCRIPT} ]] || mkdir -p ${OS_SETUP_SOURCES_DIR} && chown "$(whoami):root" ${OS_SETUP_SOURCES_DIR} && chmod -r 770 ${OS_SETUP_SOURCES_DIR}

declare -a OS_SETUP_SOURCES_SCRIPTS=$( ls ${OS_SETUP_SOURCES_DIR} )

for SCRIPT in ${OS_SETUP_SOURCES_SCRIPTS[@]};
do
	cp -f ${SCRIPT} ${OS_SETUP_SOURCES_DIR}
done

declare OS_SETUP_SCRIPTS_TRAILER='_setup.sh'

# Impostazione della variabile d'ambiente PATH in modo che comprenda anche i percorsi degli script di configurazione
[[ ${PATH} =~ "(.*:)?${OS_SETUP_SOURCES_DIR}(:.*)" ]] || (PATH=${PATH}:${OS_SETUP_SOURCES_DIR} && export PATH)

# Definizione delle espressioni regolari
declare -r COMMENT_REGEXP='[#;]\h*'

declare -r IPV4_OCTET='[0-9]{0,2}[0-9]'
declare -r IPV4_ADDRESS_REGEXP="(${IPV4_OCTET}\.){3}${IPV4_OCTET}"
declare -r IPV4_NETMASK_REGEXP="\/[0-9]{1,2}"
declare -r IPV4_COMPLETE_ADDRESS_REGEXP="${IPV4_ADDRESS_REGEXP}${IPV4_NETMASK_REGEXP}"
declare -r IPV4_COMPLETE_ADDRESS_LIST_SEPARATOR_REGEXP=", "
declare -r IPV4_COMPLETE_ADDRESS_LIST_REGEXP="(${IPV4_COMPLETE_ADDRESS_REGEXP}${IPV4_COMPLETE_ADDRESS_LIST_SEPARATO_REGEXP})*${IPV4_COMPLETE_ADDRESS_REGEXP}"
declare -r IPV4_ADDRESS_LIST_SEPARATOR_REGEXP=","
declare -r IPV4_ADDRESS_LIST_REGEXP="(${IPV4_ADDRESS_REGEXP}${IPV4_ADDRESS_LIST_SEPARATOR_REGEXP})*${IPV4_ADDRESS_REGEXP}"

declare -r HOSTNAME_REGEXP="\w+"
declare DOMAIN_NAME_COMPONENT_REGEXP="\w+"
declare DOMAIN_NAME_SEPARATOR_REGEXP="\."
declare DOMAIN_NAME_REGEXP="(${DOMAIN_NAME_COMPONENT_REGEXP}${DOMAIN_NAME_SEPARATOR_REGEXP})*${DOMAIN_NAME_COMPONENT_REGEXP}"
declare FQDN_REGEXP="${HOSTNAME_REGEXP}${DOMAIN_NAME_SEPARATOR_REGEXP}${DOMAIN_NAME_REGEXP}"

declare IPV4_SEARCH_DOMAIN_REGEXP="${DOMAIN_NAME_REGEXP}"
declare IPV4_SEARCH_DOMAIN_LIST_SEPARATOR_REGEXP=','
declare IPV4_SEARCH_DOMAIN_LIST_REGEXP="(${IPV4_SEARCH_DOMAIN_REGEXP}${IPV4_SEARCH_DOMAIN_LIST_SEAPARATOR_REGEXP})*${IPV4_SEARCH_DOMAIN_REGEXP}/$"

declare -r NTP_SERVER_ADDRESS_REGEXP="(${FQDN_REGEXP}|${IPV4_ADDRESS_REGEXP})"
declare -r NTP_TYPE_REGEXP='(server|pool)'
declare -r NTP_CONFIG_LINE_REGEXP="^${NTP_TYPE_REGEXP} ${NTP_SERVER_ADDRESS_REGEXP} iburst"

declare -r PROXY_SERVER_ADDRESS_REGEXP="(${FQDN_REGEXP}|${IPV4_ADDRESS_REGEXP})"
declare -r PORT_REGEXP="[0-9]{1,5}"

declare -i GAP=15

declare -r COMMENT='# '


declare -r DEFAULT_PROXY_SERVER='10.22.99.5'
declare -r DEFAULT_PROXY_PORT='3128'
declare -r DEFAULT_PROXY_PROTOCOL='http'

declare -a ACTIONS=('Sì' \
			  'No' \
			  'Salta' \
			  'Esci' \
			  )
