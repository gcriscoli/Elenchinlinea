#! /bin/bash

# Pulizia dello schermo e reset delle impostazioni grafiche a quelle standard
tput clear
tput sgr0

# Caricamento delle variabili d'ambiente in preordine dallo script del percorso locale, ed in subordine da quello nel percorso definitivo (nel caso siano state approtate modifiche...)
# Se le variabili d'ambiente non possono essere caricate, lo script esce con un codice d'errore non nullo
if [[ -f './os_setup_sources/env_setup.sh' ]];
then
	source './os_setup_sources/env_setup.sh'
elif [[ -f '/usr/bin/os_setup_sources/env_setup' ]];
then
	source '/usr/bin/os_setup_sources/env_setup.sh')
else
	printf "\n%s\n" "Le variabili d'ambiente non sono definite: impossibile proseguire."
	exit 1
fi

# Determina il percorso complet, il nome e la directory di lancio del presente script
declare THIS_SCRIPT=$0
declare THIS_SCRIPT_DIRNAME=$(dirname ${THIS_SCRIPT})
declare THIS_SCRIPT_BASENAME=$(basename ${THIS_SCRIPT})

# Verifica che esista una directory os_setup_sources nel percorso di installazione e, nel caso, creala
[[ -d ${OS_SETUP_SOURCES_DIR} ]] || mkdir -p ${OS_SETUP_SOURCES_DIR}

declare THIS_SCRIPT_SOURCES_DIRNAME="${THIS_SCRIPT_DIRNAME}/os_setup_sources"
declare -a THIS_SCRIPT_SOURCES_SCRIPTS=$( ls ${THIS_SCRIPT_SOURCES_DIRNAME} )

[[ -d $OS_SETUP_SCRIPT_DIR ]] || printf "${BLINKING}${RED}${BOLD}%s${NORMAL}\n" "La directory $OS_SETUP_SCRIPT_DIR non esiste"

declare -A CONFIG_SCRIPTS=([ENV]="${OS_SETUP_SOURCES_DIR}env${OS_SETUP_SCRIPTS_TRAILER}" \
						  [NTP]="${OS_SETUP_SOURCES_DIR}ntp${OS_SETUP_SCRIPTS_TRAILER}" \
						  [Hostname]="${OS_SETUP_SOURCES_DIR}hostname${OS_SETUP_SCRIPTS_TRAILER}" \
						  [Rete]="${OS_SETUP_SOURCES_DIR}network${OS_SETUP_SCRIPTS_TRAILER}" \
						  [Proxy]="${OS_SETUP_SOURCES_DIR}proxy${OS_SETUP_SCRIPTS_TRAILER}" \
						  [Firewall]="${OS_SETUP_SOURCES_DIR}firewall${OS_SETUP_SCRIPTS_TRAILER}" \
						  [SELinux]="${OS_SETUP_SOURCES_DIR}selinux${OS_SETUP_SCRIPTS_TRAILER}" \
						  [Registrazione]="${OS_SETUP_SOURCES_DIR}reg${OS_SETUP_SCRIPTS_TRAILER}" \
						  )
declare CONFIG_SCRIPT

declare -A NICE_SENTENCE=([ENV]="elle variabili d'ambiente" \
						  [NTP]="el server NTP di riferimento" \
						  [Hostname]="ell'hostname" \
						  [Rete]="ell'interfaccia di rete" \
						  [Proxy]="el server Proxy di riferimento" \
						  [Firewall]="el Firewall di sistema" \
						  [SELinux]="i SELinux" \
						  [Registrazione]="ella registrazione presso Red Hat" \
						  )

function printout_distros()
{
	for DISTRO in ${DISTROS[@]};
	do
		printf "%-2s%s\n" "-" "${DISTRO}"
	done
	printf "\n"

	return 0
}

declare -a ACTIONS=( 'NTP' 'Hostname' 'Rete' 'Proxy' 'Firewall' 'SELinux' 'Uscire')

if [[ $OS_NAME == 'Red Hat Enterprise Linux' ]];
then
	ACTIONS+='Registrazione'
fi
echo ${ACTIONS[@]}

tput clear

printf "${BOLD}${RED}%s\n\n${NORMAL}" "CONFIGURAZIONE PRELIMINARE DEL SISTEMA"

# Se la directory di lancio del presente script è diversa da quella di prevista installazione,
if [[ ! $THIS_SCRIPT_DIRNAME == $OS_SETUP_SOURCES_DIR ]];
then
	# copia il presente script nella directory di installazione ed attribuiscigli i privilegi di esecuzione corretti
	cp -f "${THIS_SCRIPT}" "${OS_SETUP_SCRIPT_DIR}" && chmod 770 "${OS_SETUP_SCRIPT}"

	# Inoltre, se la directory di lancio del presente script contiene una sottodirectory os_setup_sources,  attribuisci a tutto il suo contenuto i privilegi corretti
	if [[ -d ${THIS_SCRIPT_SOURCES_DIRNAME} ]];
	then
		for SCRIPT in ${OS_SETUP_SOURCES_SCRIPTS[@]};
		do
			echo "${SCRIPT}..."
			[[ -f ${SCRIPT} && ${SCRIPT} =~ ".*\.sh" ]] && chmod 770 "${THIS_SCRIPT_SOURCES_DIRNAME}/${SCRIPT}" && echo "Fatto!"
		done
	fi
fi

# Se la directory di installazione non contiene una sottodirectory os_setup_scripts, creala
[[ -d "${OS_SETUP_SOURCES_DIR}" ]] || mkdir -p "${OS_SETUP_SOURCES_DIR}"

# Copia tutti i files contenuti nella directory os_setup_sources del percorso di lancio nella corrispondente del percorso di installazione ed attribuisci a tutti i files i privilegi di esecuzione corretti
if [[ $(cp -fR "${THIS_SCRIPT_SOURCES_DIRNAME}" "${OS_SETUP_SOURCES_DIR}") ]];
then
	for SCRIPT in ${OS_SETUP_SOURCES_SCRIPTS[@]};
		do
			echo "${SCRIPT}..."
			[[ -f ${SCRIPT} && ${SCRIPT} =~ ".*\.sh" ]] && chmod 770 "${OS_SETUP_SOURCES_DIR}*.sh" && echo "Fatto!"
		done
fi

# Copia il file env_setup.sh nel percorso /etc/profile.d per farlo diventare una configurazione valida per tutti gli utenti
[[ -f ${CONFIG_SCRIPTS[ENV]} ]] && cp -f ${CONFIG_SCRIPTS[ENV]} "/etc/profile.d/${CONFIG_SCRIPTS[ENV]}"

printf "%s\n" "Questa procedura permette di configurare ${BOLD}agevolmente${NORMAL} un server linux basato su:"
printout_distros

printf "%s\n" "Scegliere quale aspetto del server configurare:"
select ACTION in ${ACTIONS[@]};
do
	if [[ $ACTION == 'Uscire' ]];
	then
		printf "%s\n" "Riavviare il server per rendere effettive tutte le modifiche apportate?"
		select REBOOT in 'Sì' 'No';
		do
			# Riavvio della macchia per rendere effettive le modifiche a SELinux
			[[ $REBOOT == 'Sì' ]] && shutdown -r +1 "Il sistema si riavvierà tra 1 minuto per rendere effettive tutte le modifiche..."

			# Uscita dallo script di configurazione senza riavviare
			[[ $REBOOT == 'No' ]] && exit 0
			break
		done
	else
		CONFIG_SCRIPT=${CONFIG_SCRIPTS[${ACTION}]}
		if [[ -f ${CONFIG_SCRIPT} ]];
		then
			printf "\n${RED}${BOLD}%s%s${NORMAL}\n\n" "Configurazione d" "${NICE_SENTENCE[${ACTION}]}"
			source ${CONFIG_SCRIPT}
		else
			printf "${RED}${BOLD}%s${NORMAL}\n\n$s\n" "ATTENZIONE!!!" "Lo script di configurazione ${CONFIG_SCRIPT} non esiste nel percorso corrente"
			exit 1
		fi
	fi
	
	printf "\n%s ${BOLD}%s${NORMAL} %s\n" "Premere" "INVIO" "per continuare."
done
