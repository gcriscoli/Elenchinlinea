#! /bin/bash

# Pulizia dello schermo e reset delle impostazioni grafiche a quelle standard
tput clear
tput sgr0

# Caricamento delle variabili d'ambiente in preordine dallo script del percorso locale, ed in subordine da quello nel percorso definitivo (nel caso siano state approtate modifiche...)
# Se le variabili d'ambiente non possono essere caricate, lo script esce con un codice d'errore non nullo
if [[ -f './os_setup_sources/env_setup.sh' ]];
then
	chmod +x ./os_setup_sources/env_setup.sh
	source './os_setup_sources/env_setup.sh'
elif [[ -f '/usr/bin/os_setup_sources/env_setup.sh' ]];
then
	chmod +x ./usr/bin/os_setup_sources/env_setup.sh
	source '/usr/bin/os_setup_sources/env_setup.sh'
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

declare -a CONFIGURATION_ITEMS=( 'NTP' 'Hostname' 'Rete' 'Proxy' 'Firewall' 'SELinux' 'Uscire')

if [[ $OS_NAME == 'Red Hat Enterprise Linux' ]];
then
	CONFIGURATION_ITEMS+='Registrazione'
fi
echo ${CONFIGURATION_ITEMS[@]}

tput clear

printf "${BOLD}${RED}%s\n\n${NORMAL}" "CONFIGURAZIONE PRELIMINARE DEL SISTEMA"

# Se la directory di lancio del presente script è diversa da quella di prevista installazione,
if [[ ! $THIS_SCRIPT_DIRNAME == $OS_SETUP_SOURCES_DIR ]];
then
	# copia il presente script nella directory di installazione e gli attribuisce i privilegi di esecuzione corretti
	cp -f "${THIS_SCRIPT}" "${OS_SETUP_SCRIPT_DIR}" && chmod +x "${OS_SETUP_SCRIPT}"

	# Inoltre, se la directory di lancio del presente script contiene una sottodirectory os_setup_sources,  attribuisce a tutto il suo contenuto i privilegi corretti
	[[ -d ${THIS_SCRIPT_SOURCES_DIRNAME} ]] && chmod -R +x "${THIS_SCRIPT_SOURCES_DIRNAME}"
fi

# Verifica dell'esistenza della directory di installazione degli script di configurazione o creazione della stessa con i privilegi corretti
if [[ ! -d ${OS_SETUP_SOURCES_SCRIPT} ]];
then
	mkdir -p ${OS_SETUP_SOURCES_DIR}
fi
chown -R "root:root" ${OS_SETUP_SOURCES_DIR}

chmod -R +x ${OS_SETUP_SOURCES_DIR}

# Copia di tutti i files contenuti nella directory os_setup_sources del percorso di lancio nella corrispondente del percorso di installazione ed attribuzione a tutti i files dei privilegi di esecuzione corretti
cp -fR "${THIS_SCRIPT_SOURCES_DIRNAME}" "${OS_SETUP_SCRIPT_DIR}" && chmod -R +x "${OS_SETUP_SOURCES_DIR}"

# Se il collegamento al file env_setup.sh nel percorso /etc/profile.d non esiste, viene creato per farlo diventare una configurazione valida per tutti gli utenti
[[ -f ${CONFIG_SCRIPTS[ENV]} ]] || ln -s ${CONFIG_SCRIPTS[ENV]} "/etc/profile.d/env_setup.sh"

printf "%s\n" "Questa procedura permette di configurare ${BOLD}agevolmente${NORMAL} un server linux basato su:"
printout_distros

printf "%s\t${RED}${BOLD}%s %s${NORMAL}\n" "Configurazione di un server Linux basato su:" "${THIS_OS_NAME}" "${THIS_OS_VERSION}"

printf "\n%s\n" "Scegliere quale aspetto del server configurare:"
select CONFIGURATION_ITEM in ${CONFIGURATION_ITEMS[@]};
do
	if [[ $CONFIGURATION_ITEM == 'Uscire' ]];
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
		CONFIG_SCRIPT=${CONFIG_SCRIPTS[${CONFIGURATION_ITEM}]}
		if [[ -f ${CONFIG_SCRIPT} ]];
		then
			printf "\n${RED}${BOLD}%s%s${NORMAL}\n\n" "Configurazione d" "${NICE_SENTENCE[${CONFIGURATION_ITEM}]}"
			source ${CONFIG_SCRIPT}
		else
			printf "${RED}${BOLD}%s${NORMAL}\n\n$s\n" "ATTENZIONE!!!" "Lo script di configurazione ${CONFIG_SCRIPT} non esiste nel percorso corrente"
			exit 1
		fi
	fi
	
	printf "\n%s ${BOLD}%s${NORMAL} %s\n" "Premere" "INVIO" "per continuare."
done
