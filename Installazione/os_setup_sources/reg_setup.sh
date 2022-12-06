#! /bin/bash -x

declare RHSM_DIR='/etc/rhsm/'
declare RHSM_CONF_FILE=${RHSM_DIR}'rhsm.conf'
declare RHSM_SOURCE_FILE

# Utilizza come file di riferimento prioritariamente queelo del sistema operativo o, in sua assenza, una copia slavata localmente
if [[ -f "${OS_SETUP_SOURCES_DIR}/rhsm.conf" ]];
then
	RHSM_SOURCE_FILE="${OS_SETUP_SOURCES_DIR}/rhsm.conf"
elif [[ -f "${OS_SETUP_SOURCES_DIR}/rhsm.conf" ]];
then
	RHSM_SOURCE_FILE="${OS_SETUP_SOURCES_DIR}/rhsm.conf"
fi

# Se la direcotry di configurazione esiste, ma non esiste il file di configurazione di RHSM, allora ve lo copia.
# Altrimenti,lo script esce con un codice di errore
if [[ -d ${RHSM_DIR} ]];
then
	[[ -f ${RHSM_CONF_FILE} ]] || ([[ ! -z ${RHSM_SOURCE_FILE} ]] && cp -f ${RHSM_SOURCE_FILE} ${RHSM_DIR})
else
	exit 1
fi

CURRENT_PROXY_SERVER=$(grep -E --regexp="^proxy_hostname = ${PROXY_SERVER_ADDRESS_REGEXP}/$" ${RHSM_CONF_FILE} | grep -Eo --regexp="${PROXY_SERVER_ADDRESS_REGEXP}")

CURRENT_PROXY_PORT=$(grep -E --regexp="^proxy_port = ${PORT_REGEXP}/$" ${RHSM_CONF_FILE} | grep -Eo --regexp="${PORT_REGEXP}")

CURRENT_PROXY_SCHEME=$(grep -E --regexp="^proxy_scheme = https?/$" ${RHSM_CONF_FILE} | grep -Eo --regexp='https?')

printf "%s\n" "La registrazione del prodotto può avvenire solo se le impostazioni di connessione tramite proxy sono corrette."
printf "%s" "Attualmente "
[[ -z ${CURRENT_PROXY_SERVER} ]] && printf "%s\n" "non è impostato alcun proxy" || printf "%s ${RED}${BOLD}%s${NORMAL} %s ${RED}${BOLD}%s${NORMAL} %s ${RED}${BOLD}%s${NORMAL}\n" "il proxy è impostato sull'indirizzo" "${CURRENT_PROXY_SERVER}" ", porta" "${CURRENT_PROXY_PORT}" ", con protocollo" "${CURRENT_PROXY_SCHEME}"
printf "%s" "Mantenere o modificare le impostazioni correnti?"
select CHOICE in "Mantenenre" "Modificare";
do
	[[ $CHOICE == 'Modificare' ]] && source "${OS_SETUP_SOURCES_DIR}/proxy_setup.sh"
	break
done
