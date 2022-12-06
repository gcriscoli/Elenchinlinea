#! /bin/bash

tput clear

declare OPENLDAP_VERSION='2.6.2'
declare FILE_TO_EXTRACT="openldap-${OPENLDAP_VERSION}.tgz"
declare EXTRACTION_PATH="./openldap-${OPENLDAP_VERSION}"

# Aggiornamento del sistema operativo e dei pacchetti già installati
printf "\n$(tput setaf 1)$(tput bold)%s$(tput sgr0)\n\n" "Aggiornamento del sistema operativo"
printf "%s\n" "Procedere all'aggiornamento dei pacchetti installati?"
select UPDATE in "Sì" "No" "Salta" "Esci";
do
	case $UPDATE in
	Sì)
		dnf -y update
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

tput clear

# Scaricamento dei sorgenti di OpenLDAP
printf "\n$(tput setaf 1)$(tput bold)%s$(tput sgr0)\n\n" "Scaricamento di OpenLDAP ${OPENLDAP_VERSION}"
[[ ! -f ${FILE_TO_EXTRACT} ]] && wget https://www.openldap.org/software/download/OpenLDAP/openldap-release/${FILE_TO_EXTRACT}

tput clear

# Estrazione dell'archivio
printf "\n$(tput setaf 1)$(tput bold)%s$(tput sgr0)\n\n" "Estrazione dell'archivio di OpenLDAP ${OPENLDAP_VERSION}"
[[ ! -d ${EXTRACTION_PATH} ]] && tar -xvzf ${FILE_TO_EXTRACT}

# Configurazione del prodotto
declare -a CONFIGURATIONS=( \
						  'Base' \
						  'Standard' \
						  'Modulare' \
						  'Completa' \
						  'RSIS-C4'
						  'Personalizzata' \
						  'Uscita' \
						  )

# Configurazione BASE o STANDARD di OpenLDAP
# Opzioni facoltative
declare ENABLE_DEBUG='yes'
declare ENABLE_DYNAMIC='auto'
declare ENABLE_SYSLOG='auto'
declare ENABLE_IPV6='auto'
declare ENABLE_LOCAL='auto'

# Opzioni del deomne SLAPd
declare ENABLE_SLAPD='yes'
declare ENABLE_DYNACL='no'
declare ENABLE_ACI='no'
declare ENABLE_CLEARTEXT='yes'
declare ENABLE_CRYPT='no'
declare ENABLE_SPASSWD='no'
declare ENABLE_MODULES='no'
declare ENABLE_RLOOKUPS='no'
declare ENABLE_SLAPI='no'
declare ENABLE_SLP='no'
declare ENABLE_WRAPPERS='no'

# Opzioni del back-end del demone SLAPd
declare ENABLE_BACKENDS='yes'
declare ENABLE_DNSSRV='no'
declare ENABLE_LDAP='no'
declare ENABLE_MDB='yes'
declare ENABLE_META='no'
declare ENABLE_ASYNCMETA='no'
declare ENABLE_NULL='no'
declare ENABLE_PASSWD='no'
declare ENABLE_PERL='no'
declare ENABLE_RELAY='yes'
declare ENABLE_SOCK='no'
declare ENABLE_SQL='no'
declare ENABLE_WT='no'

# Opzioni degli overlays del demone SLAPd
declare ENABLE_OVERLAYS='yes'
declare ENABLE_ACCESSLOG='no'
declare ENABLE_AUDITLOG='no'
declare ENABLE_AUTOCA='no'
declare ENABLE_COLLECT='no'
declare ENABLE_CONSTRAINT='no'
declare ENABLE_DDS='no'
declare ENABLE_DEREF='no'
declare ENABLE_DYNGROUP='no'
declare ENABLE_DYNLIST='no'
declare ENABLE_HOMEDIR='no'
declare ENABLE_MEMBEROF='no'
declare ENABLE_OTP='no'
declare ENABLE_PPOLICY='no'
declare ENABLE_PROXYCACHE='no'
declare ENABLE_REFINT='no'
declare ENABLE_REMOTEAUTH='no'
declare ENABLE_RETCODE='no'
declare ENABLE_RWM='no'
declare ENABLE_SEQMOD='no'
declare ENABLE_SSSVLV='no'
declare ENABLE_SYNCPROV='no'
declare ENABLE_TRANSLUCENT='no'
declare ENABLE_UNIQUE='no'
declare ENABLE_VALSORT='no'

# Opzioni del module Password del demone SLAPd
declare ENABLE_ARGON2='no'

# Opzioni per il demone di bilanciamento del carico (LLOADD)
declare ENABLE_BALANCER='no'

# Pacchetti aggiuntivi
declare WITH_CYRUS='auto'
declare WITH_SYSTEMD='auto'
declare WITH_FETCH='auto'
# Fedora non fornisce i pacchetti per libfetch; non trovandoli, il prodotto si autoconfigura di conseguenza
declare WITH_THREADS='auto'
declare WITH_TLS='auto'
declare WITH_YIELDINGSELECT='auto'
declare WITH_MP='auto'
declare WITH_ODBC='auto'
declare WITH_ARGON2='libargon2'
declare WITH_AIXSONAME='aix'
declare WITH_GNULD='no'

tput clear

printf "\n$(tput setaf 1)$(tput bold)%s$(tput sgr0)\n\n" "Configurazione di OpenLDAP ${OPENLDAP_VERSION}"

echo "Scegliere il tipo di configurazione di OpenLDAP ${OPENLDAP_VERSION}"
select CONFIGURATION in ${CONFIGURATIONS[@]};
do
	printf "\n%s$(tput setaf 1)$(tput bold)%20s$(tput sgr0)\n" "Modalità scelta:" "${CONFIGURATION}"

	case $CONFIGURATION in

		Base|Standard)
		;;

		Modulare)
			# Opzioni facoltative
			ENABLE_DEBUG='yes'
			ENABLE_DYNAMIC='yes'
			ENABLE_SYSLOG='yes'
			ENABLE_IPV6='no'
			ENABLE_LOCAL='yes'

			# Opzioni del demone SLAPd
			ENABLE_SLAPD='yes'
			ENABLE_DYNACL='no'
			ENABLE_ACI='no'
			ENABLE_CLEARTEXT='yes'
			ENABLE_CRYPT='yes'
			ENABLE_SPASSWD='yes'
			ENABLE_MODULES='yes'
			ENABLE_RLOOKUPS='yes'
			ENABLE_SLAPI='no'
			ENABLE_SLP='no'
			ENABLE_WRAPPERS='no'

			# Opzioni del back-end del demone SLAPd
			ENABLE_BACKENDS='no'
			ENABLE_DNSSRV='mod'
			ENABLE_LDAP='mod'
			ENABLE_MDB='mod'
			ENABLE_META='mod'
			ENABLE_ASYNCMETA='mod'
			ENABLE_NULL='mod'
			ENABLE_PASSWD='mod'
			ENABLE_PERL='no'
			ENABLE_RELAY='mod'
			ENABLE_SOCK='mod'
			ENABLE_SQL='mod'
			# ENABLE_WT='no'
			# Fedora non fornisce i pacchetti per WiredTiger, quindi il backend viene disabilitato di default. Volendo attivare il backend WT, installare prima WiredTiger come indicato in https://source.wiredtiger.com/develop/build-posix.html

			# Opzioni degli overlays del demone SLAPd
			ENABLE_OVERLAYS='no'
			ENABLE_ACCESSLOG='mod'
			ENABLE_AUDITLOG='mod'
			ENABLE_AUTOCA='mod'
			ENABLE_COLLECT='mod'
			ENABLE_CONSTRAINT='mod'
			ENABLE_DDS='mod'
			ENABLE_DEREF='mod'
			ENABLE_DYNGROUP='mod'
			ENABLE_DYNLIST='mod'
			ENABLE_HOMEDIR='mod'
			ENABLE_MEMBEROF='mod'
			ENABLE_OTP='mod'
			ENABLE_PPOLICY='mod'
			ENABLE_PROXYCACHE='mod'
			ENABLE_REFINT='mod'
			ENABLE_REMOTEAUTH='mod'
			ENABLE_RETCODE='mod'
			ENABLE_RWM='mod'
			ENABLE_SEQMOD='mod'
			ENABLE_SSSVLV='mod'
			ENABLE_SYNCPROV='mod'
			ENABLE_TRANSLUCENT='mod'
			ENABLE_UNIQUE='mod'
			ENABLE_VALSORT='mod'

			# Opzioni del modulo Password del demone SLAPd
			ENABLE_ARGON2='yes'

			# Opzioni per il demone di bilanciamento del carico (LLOADD)
			ENABLE_BALANCER='mod'

			# Pacchetti aggiuntivi
			WITH_CYRUS='yes'
			WITH_SYSTEMD='yes'
			# WITH_FETCH='no'
			# Fedora non fornisce i pacchetti per libfetch
			WITH_THREADS='auto'
			WITH_TLS='openssl'
			WITH_YIELDINGSELECT='auto'
			WITH_MP='auto'
			WITH_ODBC='unixodbc'
			WITH_ARGON2='libargon2'
			WITH_AIXSONAME='aix'
			WITH_GNULD='no'
		;;
		
		Completa)
			# Opzioni facoltative
			ENABLE_DEBUG='yes'
			ENABLE_DYNAMIC='yes'
			ENABLE_SYSLOG='yes'
			ENABLE_IPV6='no'
			ENABLE_LOCAL='yes'
	
			# Opzioni del demone SLAPd
			ENABLE_SLAPD='yes'
			ENABLE_DYNACL='no'
			ENABLE_ACI='no'
			ENABLE_CLEARTEXT='yes'
			ENABLE_CRYPT='yes'
			ENABLE_SPASSWD='yes'
			ENABLE_MODULES='yes'
			ENABLE_RLOOKUPS='yes'
			ENABLE_SLAPI='no'
			ENABLE_SLP='no'
			ENABLE_WRAPPERS='no'
	
			# Opzioni del back-end del demone SLAPd
			ENABLE_BACKENDS='no'
			ENABLE_DNSSRV='yes'
			ENABLE_LDAP='yes'
			ENABLE_MDB='yes'
			ENABLE_META='yes'
			ENABLE_ASYNCMETA='yes'
			ENABLE_NULL='yes'
			ENABLE_PASSWD='yes'
			ENABLE_PERL='no'
			ENABLE_RELAY='yes'
			ENABLE_SOCK='yes'
			ENABLE_SQL='yes'
			# ENABLE_WT='no'
			# Fedora non fornisce i pacchetti per WiredTiger, quindi il backend viene disabilitato di default. Volendo attivare il backend WT, installare prima WiredTiger come indicato in https://source.wiredtiger.com/develop/build-posix.html
	
			# Opzioni degli overlays del demone SLAPd
			ENABLE_OVERLAYS='no'
			ENABLE_ACCESSLOG='yes'
			ENABLE_AUDITLOG='yes'
			ENABLE_AUTOCA='yes'
			ENABLE_COLLECT='yes'
			ENABLE_CONSTRAINT='yes'
			ENABLE_DDS='yes'
			ENABLE_DEREF='yes'
			ENABLE_DYNGROUP='yes'
			ENABLE_DYNLIST='yes'
			ENABLE_HOMEDIR='yes'
			ENABLE_MEMBEROF='yes'
			ENABLE_OTP='yes'
			ENABLE_PPOLICY='yes'
			ENABLE_PROXYCACHE='yes'
			ENABLE_REFINT='yes'
			ENABLE_REMOTEAUTH='yes'
			ENABLE_RETCODE='yes'
			ENABLE_RWM='yes'
			ENABLE_SEQMOD='yes'
			ENABLE_SSSVLV='yes'
			ENABLE_SYNCPROV='yes'
			ENABLE_TRANSLUCENT='yes'
			ENABLE_UNIQUE='yes'
			ENABLE_VALSORT='yes'
	
			# Opzioni del yesulo Password del demone SLAPd
			ENABLE_ARGON2='yes'

			# Opzioni per il demone di bilanciamento del carico (LLOADD)
			ENABLE_BALANCER='yes'
	
			# Pacchetti aggiuntivi
			WITH_CYRUS='yes'
			WITH_SYSTEMD='yes'
			# WITH_FETCH='no'
			# Fedora non fornisce i pacchetti per libfetch
			WITH_THREADS='auto'
			WITH_TLS='openssl'
			WITH_YIELDINGSELECT='auto'
			WITH_MP='auto'
			WITH_ODBC='unixodbc'
			WITH_ARGON2='libargon2'
			WITH_AIXSONAME='aix'
			WITH_GNULD='no'
		;;
	
		'RSIS-C4')
			# Opzioni facoltative
			ENABLE_DEBUG='yes'
			ENABLE_DYNAMIC='yes'
			ENABLE_SYSLOG='yes'
			ENABLE_IPV6='no'
			ENABLE_LOCAL='yes'
	
			# Opzioni del demone SLAPd
			ENABLE_SLAPD='yes'
			ENABLE_DYNACL='no'
			ENABLE_ACI='no'
			ENABLE_CLEARTEXT='yes'
			ENABLE_CRYPT='yes'
			ENABLE_SPASSWD='yes'
			ENABLE_MODULES='yes'
			ENABLE_RLOOKUPS='yes'
			ENABLE_SLAPI='no'
			ENABLE_SLP='no'
			ENABLE_WRAPPERS='no'
	
			# Opzioni del back-end del demone SLAPd
			ENABLE_BACKENDS='yes'
			ENABLE_DNSSRV='yes'
			ENABLE_LDAP='yes'
			ENABLE_MDB='yes'
			ENABLE_META='yes'
			ENABLE_ASYNCMETA='yes'
			ENABLE_NULL='yes'
			ENABLE_PASSWD='yes'
			ENABLE_PERL='no'
			ENABLE_RELAY='yes'
			ENABLE_SOCK='yes'
			ENABLE_SQL='yes'
			# ENABLE_WT='no'
			# Fedora non fornisce i pacchetti per WiredTiger, quindi il backend viene disabilitato di default. Volendo attivare il backend WT, installare prima WiredTiger come indicato in https://source.wiredtiger.com/develop/build-posix.html
	
			# Opzioni degli overlays del demone SLAPd
			ENABLE_OVERLAYS='yes'
			ENABLE_ACCESSLOG='yes'
			ENABLE_AUDITLOG='yes'
			ENABLE_AUTOCA='yes'
			ENABLE_COLLECT='yes'
			ENABLE_CONSTRAINT='yes'
			ENABLE_DDS='yes'
			ENABLE_DEREF='yes'
			ENABLE_DYNGROUP='yes'
			ENABLE_DYNLIST='yes'
			ENABLE_HOMEDIR='yes'
			ENABLE_MEMBEROF='yes'
			ENABLE_OTP='yes'
			ENABLE_PPOLICY='yes'
			ENABLE_PROXYCACHE='yes'
			ENABLE_REFINT='yes'
			ENABLE_REMOTEAUTH='yes'
			ENABLE_RETCODE='yes'
			ENABLE_RWM='yes'
			ENABLE_SEQMOD='yes'
			ENABLE_SSSVLV='yes'
			ENABLE_SYNCPROV='yes'
			ENABLE_TRANSLUCENT='yes'
			ENABLE_UNIQUE='yes'
			ENABLE_VALSORT='yes'
	
			# Opzioni del modulo Password del demone SLAPd
			ENABLE_ARGON2='yes'
	
			# Opzioni per il demone di bilanciamento del carico (LLOADD)
			ENABLE_BALANCER='yes'
	
			# Pacchetti aggiuntivi
			WITH_CYRUS='yes'
			WITH_SYSTEMD='yes'
			# WITH_FETCH='no'
			# Fedora non fornisce i pacchetti per libfetch
			WITH_THREADS='auto'
			WITH_TLS='openssl'
			WITH_YIELDINGSELECT='auto'
			WITH_MP='auto'
			WITH_ODBC='unixodbc'
			WITH_ARGON2='libargon2'
			WITH_AIXSONAME='aix'
			WITH_GNULD='no'
		;;

		Personalizzata)

			function select_with_odbc()
			{
					local -a OPTIONS=('iodbc' 'unixodbc' 'odbc32' 'auto')

					# Supporto specifico per ODBC
					printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Quale supporto specifico per" "ODBC" "si desidera attivare?"
					select WITH_ODBC in ${OPTIONS[@]};
					do
						break
					done
			}

			function select_with_argon2()
			{
					local -a OPTIONS=('auto' 'libargon2' 'libsodium')

					# Librerie specifiche per il supporto di Argon2
					printf "%s $(tput bold)%s$(tput sgr0)$s\n" "Quale" "libreria per il supporto di Argon2" "si intende attivare?"
					select WITH_ARGON2 in ${OPTIONS[@]};
					do
						break
					done
			}

			function select_backends_enable_mode()
				{
					if [[ ! $# == 0 ]];
					then
							if [[ $1 =~ (yes|no|mod) ]];
							then
								[[ $1 == 'mod' ]] && ENABLE_MODULES='yes'
								[[ $1 =~ (yes|mod) ]]&& ENABLE_BACKENDS='yes'

								ENABLE_DNSSRV=$1
								ENABLE_LDAP=$1
								ENABLE_MDB=$1
								ENABLE_META=$1
								ENABLE_ASYNCMETA=$1
								ENABLE_NULL=$1
								ENABLE_PASSWD=$1
								ENABLE_PERL=$1
								ENABLE_RELAY=$1
								ENABLE_SOCK=$1
								ENABLE_SQL=$1
								# ENABLE_WT='no'
								# Fedora non fornisce i pacchetti per WiredTiger, quindi il backend viene disabilitato di default. Volendo attivare il backend WT, installare prima WiredTiger come indicato in https://source.wiredtiger.com/develop/build-posix.html
							else
								printf "$(tput setaf 1)$(tput bold)%s$(tput sgr0) %s\n\n" "$1" ": opzione non valida"
							fi
					else
						local -a OPTIONS=('yes' 'no' 'mod')

						# DNSSRV
						printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare il backend" "DNSSRV" "?" "$(tput bold)no$(tput sgr0)|yes|mod"
						select ENABLE_DNSSRV in ${OPTIONS[@]};
						do
							[[ $ENABLE_DNSSRV == 'mod' ]] && ENABLE_MODULES='yes'
							[[ $ENABLE_DNSSRV =~ (yes|mod) ]]&& ENABLE_BACKENDS='yes'
							break
						done

						# LDAP
						printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare il backend" "LDAP" "?" "$(tput bold)no$(tput sgr0)|yes|mod"
						select ENABLE_LDAP in ${OPTIONS[@]};
						do
							[[ $ENABLE_LDAP == 'mod' ]] && ENABLE_MODULES='yes'
							[[ $ENABLE_LDAP =~ (yes|mod) ]]&& ENABLE_BACKENDS='yes'
							break
						done

						# MDB
						printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare il backend" "MDB" "?" "no|$(tput bold)yes$(tput sgr0)|mod"
						select ENABLE_MDB in ${OPTIONS[@]};
						do
							[[ $ENABLE_MDB == 'mod' ]] && ENABLE_MODULES='yes'
							[[ $ENABLE_MDB =~ (yes|mod) ]]&& ENABLE_BACKENDS='yes'
							break
						done

						# META
						printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare il backend" "META" "?" "$(tput bold)no$(tput sgr0)|yes|mod"
						select ENABLE_META in ${OPTIONS[@]};
						do
							[[ $ENABLE_META == 'mod' ]] && ENABLE_MODULES='yes'
							[[ $ENABLE_META =~ (yes|mod) ]]&& ENABLE_BACKENDS='yes'
							break
						done

						# ASYNCMETA
						printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare il backend" "ASYNCMETA" "?" "$(tput bold)no$(tput sgr0)|yes|mod"
						select ENABLE_ASYNCMETA in ${OPTIONS[@]};
						do
							[[ $ENABLE_ASYNCMETA == 'mod' ]] && ENABLE_MODULES='yes'
							[[ $ENABLE_ASYNCMETA =~ (yes|mod) ]]&& ENABLE_BACKENDS='yes'
							break
						done

						# NULL
						printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare il backend" "NULL" "?" "$(tput bold)no$(tput sgr0)|yes|mod"
						select ENABLE_NULL in ${OPTIONS[@]};
						do
							[[ $ENABLE_NULL == 'mod' ]] && ENABLE_MODULES='yes'
							[[ $ENABLE_NULL =~ (yes|mod) ]]&& ENABLE_BACKENDS='yes'
							break
						done

						# PASSWD
						printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare il backend" "PASSWD" "?" "$(tput bold)no$(tput sgr0)|yes|mod"
						select ENABLE_PASSWD in ${OPTIONS[@]};
						do
							[[ $ENABLE_PASSWD == 'mod' ]] && ENABLE_MODULES='yes'
							[[ $ENABLE_PASSWD =~ (yes|mod) ]]&& ENABLE_BACKENDS='yes'
							break
						done

						# PERL
						printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare il backend" "PERL" "?" "$(tput bold)no$(tput sgr0)|yes|mod"
						select ENABLE_PERL in ${OPTIONS[@]};
						do
							[[ $ENABLE_PERL == 'mod' ]] && ENABLE_MODULES='yes'
							[[ $ENABLE_PERL =~ (yes|mod) ]]&& ENABLE_BACKENDS='yes'
							break
						done

						# RELAY
						printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare il backend" "RELAY" "?" "no|$(tput bold)yes$(tput sgr0)|mod"
						select ENABLE_RELAY in ${OPTIONS[@]};
						do
							[[ $ENABLE_RELAY == 'mod' ]] && ENABLE_MODULES='yes'
							[[ $ENABLE_RELAY =~ (yes|mod) ]]&& ENABLE_BACKENDS='yes'
							break
						done

						# SOCK
						printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare il backend" "SOCK" "?" "$(tput bold)no$(tput sgr0)|yes|mod"
						select ENABLE_SOCK in ${OPTIONS[@]};
						do
							[[ $ENABLE_SOCK == 'mod' ]] && ENABLE_MODULES='yes'
							[[ $ENABLE_SOCK =~ (yes|mod) ]]&& ENABLE_BACKENDS='yes'
							break
						done

						# SQL
						printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare il backend" "SQL" "?" "$(tput bold)no$(tput sgr0)|yes|mod"
						select ENABLE_SQL in ${OPTIONS[@]};
						do
							[[ $ENABLE_SQL == 'mod' ]] && ENABLE_MODULES='yes'
							[[ $ENABLE_SQL =~ (mod|yes) ]] && ENABLE_BACKENDS='yes' && select_with_odbc
							break
						done

						# WT
						#printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare il backend" "WT" "?" "$(tput bold)no$(tput sgr0)|yes|mod"
						#select ENABLE_WT in ${OPTIONS[@]};
						#do
						#	[[ $ENABLE_WT == 'mod' ]] && ENABLE_MODULES='yes'
						#	break
						#done
						# Fedora non fornisce i pacchetti per WiredTiger, quindi il backend viene disabilitato di default. Volendo attivare il backend WT, installare prima WiredTiger come indicato in https://source.wiredtiger.com/develop/build-posix.html
					fi
				}

				function select_overlays_enable_mode()
				{
					if [[ ! $# == 0 ]];
					then
							if [[ $1 =~ (yes|no|mod) ]];
							then
								[[ $1 == 'mod' ]] && ENABLE_MODULES='yes'
								[[ $1 =~ (yes|mod) ]]&& ENABLE_OVERLAYS='yes'

								ENABLE_ACCESSLOG=$1
								ENABLE_AUDITLOG=$1
								ENABLE_AUTOCA=$1
								ENABLE_COLLECT=$1
								ENABLE_CONSTRAINT=$1
								ENABLE_DDS=$1
								ENABLE_DEREF=$1
								ENABLE_DYNGROUP=$1
								ENABLE_DYNLIST=$1
								ENABLE_HOMEDIR=$1
								ENABLE_MEMBEROF=$1
								ENABLE_OTP=$1
								ENABLE_PPOLICY=$1
								ENABLE_PROXYCACHE=$1
								ENABLE_REFINT=$1
								ENABLE_REMOTEAUTH=$1
								ENABLE_RETCODE=$1
								ENABLE_RWM=$1
								ENABLE_SEQMOD=$1
								ENABLE_SSSVLV=$1
								ENABLE_SYNCPROV=$1
								ENABLE_TRANSLUCENT=$1
								ENABLE_UNIQUE=$1
								ENABLE_VALSORT=$1
							else
								printf "$(tput setaf 1)$(tput bold)%s$(tput sgr0) %s\n\n" "$1" ": opzione non valida"
							fi
					else
						local -a OPTIONS=('yes' 'no' 'mod')

						# ACCESSLOG
						printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare l'ovarlay" "ACCESSLOG" "?" "$(tput bold)no$(tput sgr0)|yes|mod"
						select ENABLE_ACCESSLOG in ${OPTIONS[@]};
						do
							[[ $ENABLE_ACCESSLOG == 'mod' ]] && ENABLE_MODULES='yes'
							[[ $ENABLE_ACCESSLOG =~ (yes|mod) ]] && ENABLE_OVERLAYS='yes'
							break
						done

						# AUDITLOG
						printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare l'ovarlay" "AUDITLOG" "?" "$(tput bold)no$(tput sgr0)|yes|mod"
						select ENABLE_AUDITLOG in ${OPTIONS[@]};
						do
							[[ $ENABLE_AUDITLOG == 'mod' ]] && ENABLE_MODULES='yes'
							[[ $ENABLE_AUDITLOG =~ (yes|mod) ]] && ENABLE_OVERLAYS='yes'
							break
						done

						# AUTOCA
						printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare l'ovarlay" "AUTOCA" "?" "$(tput bold)no$(tput sgr0)|yes|mod"
						select ENABLE_AUTOCA in ${OPTIONS[@]};
						do
							[[ $ENABLE_AUTOCA == 'mod' ]] && ENABLE_MODULES='yes'
							[[ $ENABLE_AUTOCA =~ (yes|mod) ]] && ENABLE_OVERLAYS='yes' && WITH_TLS='openssl'
							break
						done

						# COLLECT
						printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare l'ovarlay" "COLLECT" "?" "$(tput bold)no$(tput sgr0)|yes|mod"
						select ENABLE_COLLECT in ${OPTIONS[@]};
						do
							[[ $ENABLE_COLLECT == 'mod' ]] && ENABLE_MODULES='yes'
							[[ $ENABLE_COLLECT =~ (yes|mod) ]] && ENABLE_OVERLAYS='yes'
							break
						done

						# CONSTRAINT
						printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare l'ovarlay" "CONSTRAINT" "?" "$(tput bold)no$(tput sgr0)|yes|mod"
						select ENABLE_CONSTRAINT in ${OPTIONS[@]};
						do
							[[ $ENABLE_CONSTRAINT == 'mod' ]] && ENABLE_MODULES='yes'
							[[ $ENABLE_CONSTRAINT =~ (yes|mod) ]] && ENABLE_OVERLAYS='yes'
							break
						done

						# DDS
						printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare l'ovarlay" "DDS" "?" "$(tput bold)no$(tput sgr0)|yes|mod"
						select ENABLE_DDS in ${OPTIONS[@]};
						do
							[[ $ENABLE_DDS == 'mod' ]] && ENABLE_MODULES='yes'
							[[ $ENABLE_DDS =~ (yes|mod) ]] && ENABLE_OVERLAYS='yes'
							break
						done

						# DEREF
						printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare l'ovarlay" "DEREF" "?" "$(tput bold)no$(tput sgr0)|yes|mod"
						select ENABLE_DEREF in ${OPTIONS[@]};
						do
							[[ $ENABLE_DEREF == 'mod' ]] && ENABLE_MODULES='yes'
							[[ $ENABLE_DEREF =~ (yes|mod) ]] && ENABLE_OVERLAYS='yes'
							break
						done

						# DYNGROUP
						printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare l'ovarlay" "DYNGROUP" "?" "$(tput bold)no$(tput sgr0)|yes|mod"
						select ENABLE_DYNGROUP in ${OPTIONS[@]};
						do
							[[ $ENABLE_DYNGROUP == 'mod' ]] && ENABLE_MODULES='yes'
							[[ $ENABLE_DYNGROUP =~ (yes|mod) ]] && ENABLE_OVERLAYS='yes'
							break
						done

						# DYNLIST
						printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare l'ovarlay" "DYNLIST" "?" "$(tput bold)no$(tput sgr0)|yes|mod"
						select ENABLE_DYNLIST in ${OPTIONS[@]};
						do
							[[ $ENABLE_DYNLIST == 'mod' ]] && ENABLE_MODULES='yes'
							break
						done

						# HOMEDIR
						printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare l'ovarlay" "HOMEDIR" "?" "$(tput bold)no$(tput sgr0)|yes|mod"
						select ENABLE_HOMEDIR in ${OPTIONS[@]};
						do
							[[ $ENABLE_HOMEDIR == 'mod' ]] && ENABLE_MODULES='yes'
							[[ $ENABLE_HOMEDIR =~ (yes|mod) ]] && ENABLE_OVERLAYS='yes'
							break
						done

						# MEMBEROF
						printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare l'ovarlay" "MEMBEROF" "?" "$(tput bold)no$(tput sgr0)|yes|mod"
						select ENABLE_MEMBEROF in ${OPTIONS[@]};
						do
							[[ $ENABLE_MEMBEROF == 'mod' ]] && ENABLE_MODULES='yes'
							[[ $ENABLE_MEMBEROF =~ (yes|mod) ]] && ENABLE_OVERLAYS='yes'
							break
						done

						# OTP
						printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare l'ovarlay" "OTP" "?" "$(tput bold)no$(tput sgr0)|yes|mod"
						select ENABLE_OTP in ${OPTIONS[@]};
						do
							[[ $ENABLE_OTP == 'mod' ]] && ENABLE_MODULES='yes'
							[[ $ENABLE_OTP =~ (yes|mod) ]] && ENABLE_OVERLAYS='yes'
							break
						done

						# PPOLICY
						printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare l'ovarlay" "PPOLICY" "?" "$(tput bold)no$(tput sgr0)|yes|mod"
						select ENABLE_PPOLICY in ${OPTIONS[@]};
						do
							[[ $ENABLE_PPOLICY == 'mod' ]] && ENABLE_MODULES='yes'
							[[ $ENABLE_PPOLICY =~ (yes|mod) ]] && ENABLE_OVERLAYS='yes'
							break
						done

						# PROXYCACHE
						printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare l'ovarlay" "PROXYCACHE" "?" "$(tput bold)no$(tput sgr0)|yes|mod"
						select ENABLE_PROXYCACHE in ${OPTIONS[@]};
						do
							[[ $ENABLE_PROXYCACHE == 'mod' ]] && ENABLE_MODULES='yes'
							[[ $ENABLE_PROXYCACHE =~ (yes|mod) ]] && ENABLE_OVERLAYS='yes'
							break
						done

						# REFINT
						printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare l'ovarlay" "REFINT" "?" "$(tput bold)no$(tput sgr0)|yes|mod"
						select ENABLE_REFINT in ${OPTIONS[@]};
						do
							[[ $ENABLE_REFINT == 'mod' ]] && ENABLE_MODULES='yes'
							break
						done

						# REMOTEAUTH
						printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare l'ovarlay" "REMOTEAUTH" "?" "$(tput bold)no$(tput sgr0)|yes|mod"
						select ENABLE_REMOTEAUTH in ${OPTIONS[@]};
						do
							[[ $ENABLE_REMOTEAUTH == 'mod' ]] && ENABLE_MODULES='yes'
							[[ $ENABLE_REFINT =~ (yes|mod) ]] && ENABLE_OVERLAYS='yes'
							break
						done

						# RETCODE
						printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare l'ovarlay" "RETCODE" "?" "$(tput bold)no$(tput sgr0)|yes|mod"
						select ENABLE_RETCODE in ${OPTIONS[@]};
						do
							[[ $ENABLE_RETCODE == 'mod' ]] && ENABLE_MODULES='yes'
							[[ $ENABLE_RETCODE =~ (yes|mod) ]] && ENABLE_OVERLAYS='yes'
							break
						done

						# RWM
						printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare l'ovarlay" "RWM" "?" "$(tput bold)no$(tput sgr0)|yes|mod"
						select ENABLE_RWM in ${OPTIONS[@]};
						do
							[[ $ENABLE_RWM == 'mod' ]] && ENABLE_MODULES='yes'
							[[ $ENABLE_RWM =~ (yes|mod) ]] && ENABLE_OVERLAYS='yes'
							break
						done

						# SEQMOD
						printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare l'ovarlay" "SEQMOD" "?" "$(tput bold)no$(tput sgr0)|yes|mod"
						select ENABLE_SEQMOD in ${OPTIONS[@]};
						do
							[[ $ENABLE_SEQMOD == 'mod' ]] && ENABLE_MODULES='yes'
							break
						done

						# SSSVLV
						printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare l'ovarlay" "SSSVLV" "?" "$(tput bold)no$(tput sgr0)|yes|mod"
						select ENABLE_SSSVLV in ${OPTIONS[@]};
						do
							[[ $ENABLE_SSSVLV == 'mod' ]] && ENABLE_MODULES='yes'
							[[ $ENABLE_SSSVLV =~ (yes|mod) ]] && ENABLE_OVERLAYS='yes'
							break
						done

						# SYNCPROV
						printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare l'ovarlay" "SYNCPROV" "?" "no|$(tput bold)yes$(tput sgr0)|mod"
						select ENABLE_SYNCPROV in ${OPTIONS[@]};
						do
							[[ $ENABLE_SYNCPROV == 'mod' ]] && ENABLE_MODULES='yes'
							[[ $ENABLE_SYNCPROV =~ (yes|mod) ]] && ENABLE_OVERLAYS='yes'
							break
						done

						# TRANSLUCENT
						printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare l'ovarlay" "TRANSLUCENT" "?" "$(tput bold)no$(tput sgr0)|yes|mod"
						select ENABLE_TRANSLUCENT in ${OPTIONS[@]};
						do
							[[ $ENABLE_TRANSLUCENT == 'mod' ]] && ENABLE_MODULES='yes'
							[[ $ENABLE_TRANSLUCENT =~ (yes|mod) ]] && ENABLE_OVERLAYS='yes'
							break
						done

						# UNIQUE
						printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare l'ovarlay" "UNIQUE" "?" "$(tput bold)no$(tput sgr0)|yes|mod"
						select ENABLE_UNIQUE in ${OPTIONS[@]};
						do
							[[ $ENABLE_UNIQUE == 'mod' ]] && ENABLE_MODULES='yes'
							[[ $ENABLE_UNIQUE =~ (yes|mod) ]] && ENABLE_OVERLAYS='yes'
							break
						done

						# VALSORT
						printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare l'ovarlay" "VALSORT" "?" "$(tput bold)no$(tput sgr0)|yes|mod"
						select ENABLE_VALSORT in ${OPTIONS[@]};
						do
							[[ $ENABLE_VALSORT == 'mod' ]] && ENABLE_MODULES='yes'
							[[ $ENABLE_VALSORT =~ (yes|mod) ]] && ENABLE_OVERLAYS='yes'
							break
						done
					fi
				}

			declare -a OPTIONS

			# Opzioni facoltative
				# Debugging
				OPTIONS=('no' 'yes' 'traditional')

				printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare il" "debugging" "?" "no|$(tput bold)yes$(tput sgr0)|traditional"

				select ENABLE_DEBUG in ${OPTIONS[@]};
				do
					break
				done

			# Impostazione di OPTIONS per tutti i casi che seguono
			OPTIONS=('no' 'yes' 'auto')

				# Collegamento dinamico delle librerie
				printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare i files binari collegati con" "librerie dinamiche" "?" "no$(tput sgr0)|yes|$(tput bold)auto$(tput sgr0)"

				select ENABLE_DYNAMIC in ${OPTIONS[@]};
				do
					break
				done

				# Log di sistema
				printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare il supporto per i" "log di sistema" "?" "no$(tput sgr0)|yes|$(tput bold)auto$(tput sgr0)"

				select ENABLE_SYSLOG in ${OPTIONS[@]};
				do
					break
				done

				# IPv6
				printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare il supporto per" "IPv6" "?" "no$(tput sgr0)|yes|$(tput bold)auto$(tput sgr0)"

				select ENABLE_IPV6 in ${OPTIONS[@]}
				do
					break
				done

				# Socket AF_LOCAL
				printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare il supporto per il" "socket AF_LOCAL (AF_UNIX)" "?" "no$(tput sgr0)|yes|$(tput bold)auto$(tput sgr0)"

				select ENABLE_LOCAL in ${OPTIONS[@]};
				do
					break
				done

			# Opzioni del demone SLAPd
				OPTIONS=('no' 'yes')
				
				# Building del demone SLAPd
				printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Abilitare il building del" "demone SLAPd" "?" "no|$(tput bold)yes$(tput sgr0)"

				select ENABLE_SLAPD in ${OPTIONS[@]};
				do
					break
				done

				# ACL caricabili a run-time
				printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare il supporto per le" "ACL caricabili a run-time" "? (Sperimentale)" "$(tput bold)no$(tput sgr0)|yes"

				select ENABLE_DYNACL in ${OPTIONS[@]};
				do
				break
				done

				# Password in chiaro
				printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare il supporto per le" "password in chiaro" "?" "no|$(tput bold)yes$(tput sgr0)"

				select ENABLE_CLEARTEXT in ${OPTIONS[@]};
				do
					break
				done

				# Password crypt(3)
				printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare il supporto per le" "password crypt(3)" "?" "$(tput bold)no$(tput sgr0)|yes"

				select ENABLE_CRYPT in ${OPTIONS[@]};
				do
					# Opzioni del modulo Password del demone SLAPd
					if [[ $ENABLE_CRYPT == 'yes' ]];
					then
						printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare il modulo per l'" "hashing delle password Argon2" "?" "$(tput bold)no$(tput sgr0)|yes"
						select ENABLE_ARGON2 in ${OPTIONS[@]};
						do
							case $ENABLE_ARGON2 in
								yes)
									select_with_argon2
								;;

								no)
								;;
							esac
							break
						done
					fi
					break
				done

				# Verifica delle password con Cyrus SASL
				printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare la verifica delle password con" "Cyrus SASL" "?" "$(tput bold)no$(tput sgr0)|yes"

				select ENABLE_SPASSWD in ${OPTIONS[@]};
				do
					case $ENABLE_SPASSWD in
					yes)
						WITH_CYRUS='yes'
					;;

					no)
						WITH_CYRUS='no'
					;;
					esac
					break
				done

				# Moduli dinamici
				printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare il supporto per i" "moduli dinamici" "?" "$(tput bold)no$(tput sgr0)|yes"

				select ENABLE_MODULES in ${OPTIONS[@]};
				do
					break
				done

				# Reverse lookup
				printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare il" "reverse lookup " "dei clients?" "$(tput bold)no$(tput sgr0)|yes"

				select ENABLE_RLOOKUPS in ${OPTIONS[@]};
				do
					break
				done

				# SLAPi
				printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare il supporto per" "SLAPi" "? (Sperimentale)" "$(tput bold)no$(tput sgr0)|yes"

				select ENABLE_SLAPI in ${OPTIONS[@]};
				do
					break
				done

				# SLPv2
				printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare il supporto per" "SLPv2" "? (Service Locator Protocol)" "$(tput bold)no$(tput sgr0)|yes"

				select ENABLE_SLP in ${OPTIONS[@]};
				do
					break
				done

				# Wrapper TCP
				printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare i" "wrapper TCP" " (deprecato)?" "$(tput bold)no$(tput sgr0)|yes"

				select ENABLE_WRAPPERS in ${OPTIONS[@]};
				do
					break
				done
				
			# Impostazione di OPTIONS per tutti i casi che seguono
			OPTIONS=('no' 'yes' 'mod')
			
			# Opzioni relative al demone SLAPd
				# ACI per singolo oggetto
				printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare le" "ACI per singolo oggetto" "? (Sperimentale)" "$(tput bold)no$(tput sgr0)|yes|mod"

				select ENABLE_ACI in ${OPTIONS[@]};
				do
					[[ $ENABLE_ACI == 'mod' ]] && ENABLE_MODULES='yes'
					break
				done

				

			# Opzioni relative ai back-ends
				# Attivazione dei back-ends
				printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Abilitare i" "back-ends" "?" "no|yes|mod"

				select ENABLE_BACKENDS in ${OPTIONS[@]};
				do
					case $ENABLE_BACKENDS in
					yes|mod)
						[[ $ENABLE_BACKENDS == 'mod' ]] && ENABLE_MODULES='yes'
						printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare" "tutti i back-end disponibili con le stesse modalità" "?" "no|yes"
						select ALL_BACKENDS_IDENTICAL in 'no' 'yes';
						do
							case $ALL_BACKENDS_IDENTICAL in
								yes)
									printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Scegliere" "la modalità di attivazione" "?" "no|yes|mod"
									select ALL_BACKENDS_MODE in 'no' 'yes' 'mod';
									do
										select_backends_enable_mode $ALL_BACKENDS_MODE
										break
									done
								;;

								no)
									select_backends_enable_mode
								;;
							esac
							break
						done
					;;
					no)
						select_backends_enable_mode
					;;
					esac
					break
				done

			# Opzioni relative agli overlays
			# OPTIONS=('yes' 'no' 'mod')

				# Attivazione degli overlays
				printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Abilitare gli" "overlays" "?" "no|yes|mod"

				select ENABLE_OVERLAYS in ${OPTIONS[@]};
				do
					case $ENABLE_OVERLAYS in
					yes|mod)
						[[ $ENABLE_OVERLAYS == 'mod' ]] && ENABLE_MODULES='yes'
						printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare" "tutti gli overlays disponibili con le stesse modalità" "?" "no|yes"
						select ALL_OVERLAYS_IDENTICAL in 'no' 'yes';
						do
							case $ALL_OVERLAYS_IDENTICAL in
								yes)
									printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Scegliere" "la modalità di attivazione" "?" "no|yes|mod"
									select ALL_OVERLAYS_MODE in 'no' 'yes' 'mod';
									do
										select_overlays_enable_mode $ALL_OVERLAYS_MODE
										break
									done
								;;

								no)
									select_overlays_enable_mode
								;;
							esac
							break
						done
					;;
					no)
						select_overlays_enable_mode
					;;
					esac
					break
				done

			# Opzioni per il demone di bilanciamento del carico (LLOADD)
			printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare il demone per il" "bilanciamento del carico" "?" "$(tput bold)no$(tput sgr0)|yes|mod"

			select ENABLE_BALANCER in ${OPTIONS[@]};
			do
				[[ $ENABLE_BALANCER == 'mod' ]] && ENABLE_MODULES='yes'
				break
			done

		# Pacchetti aggiuntivi

		# Reimpostazione di OPTIONS per gli elementi a seguire
		OPTIONS=('no' 'yes' 'auto')

			# SystemD
			printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare il supporto per il servizio di notifica di" "SystemD" "?" "no|yes|$(tput bold)auto$(tput sgr0)"

			select WITH_SYSTEMD in ${OPTIONS[@]};
			do
				break
			done

			# Fetch degli URL
			#printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare il supporto per il" "fetch degli URL" "?" "no|yes|$(tput bold)auto$(tput sgr0)"

			#select WITH_FETCH in ${OPTIONS[@]};
			#do
			#		break
			#done
			# Fedora non fornisce i pacchetti per libfetch

			# Yielding select
			printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare il supporto per " "yielding select" "?" "no|yes|$(tput bold)auto$(tput sgr0)"

			select WITH_YIELDINGSELECT in ${OPTIONS[@]};
			do
				break
			done

			# Supporto per GNU-LD
			printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare il supporto per" "GNU-LD" "?" "$(tput bold)no$(tput sgr0)|yes|auto"

			select WITH_GNULD in ${OPTIONS[@]};
			do
				break
			done

			# Threads
			printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare il supporto per i" "thread" "?" "$(tput bold)auto$(tput sgr0)|nt|posix|pth|lwp|manual"

			OPTIONS=('auto' 'nt' 'posix' 'pth' 'lwp' 'manual')
			select WITH_THREADS in ${OPTIONS[@]};
			do
					break
			done

			# TLS/SSL
			printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare il supporto per" "TLS/SSL" "?" "$(tput bold)auto$(tput sgr0)|openssl|gnutls"

			OPTIONS=('auto' 'openssl' 'gnutls')
			select WITH_TLS in ${OPTIONS[@]};
			do
				break
			done

			# Statistiche a precisione multipla
			printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare il supporto per le" "statistiche a precisione multipla" "?" "$(tput bold)auto$(tput sgr0)|longlong|long|bignum|gmp"

			OPTIONS=('auto' 'longlong' 'long' 'bignum' 'gmp')
			select WITH_MP in ${OPTIONS[@]};
			do
				break
			done

			# Supporto per AIX-SOName
			printf "\n%s $(tput bold)%s$(tput sgr0)%s\n(%s)\n" "Attivare il supporto per" "AIX-SOName" "?" "$(tput bold)aix$(tput sgr0)|srv4|both"

			OPTIONS=('aix' 'srv4' 'both')
			select WITH_AIXSONAME in ${OPTIONS[@]};
			do
				break
			done

		;;

		Uscita)
			exit 1
		;;
	esac
	break
done

# Installazione dei pacchetti necessari

tput clear

printf "\n$(tput setaf 1)$(tput bold)%s$(tput sgr0)\n\n" "Installazione dei pacchetti necessari"

dnf -qy install gcc make langpacks-it langpacks-en glibc-all-langpacks

localectl set-locale LANG=it_IT

dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
dnf config-manager --enable epel epel-modular

/usr/bin/crb enable

dnf -y install libtool-ltdl libtool-ltdl-devel libevent libevent-devel libevent-doc argon2 libargon2 libargon2-devel libsodium-devel libsodium-static cyrus-sasl cyrus-sasl-devel cyrus-sasl-gs2 cyrus-sasl-md5 cyrus-sasl-ntlm cyrus-sasl-scram perl libiodbc libiodbc-devel unixODBC unixODBC-devel systemd-devel openssl openssl-devel gnutls gnutls-devel

declare SW_PACKAGES_TO_INSTALL=""


[[ $ENABLE_AUTOCA =~ (yes|mod) ]] && WITH_TLS='openssl'
[[ $ENABLE_ACI == 'yes' ]] && ENABLE_ACL='yes'
[[ $ENABLE_ACI == 'mod' ]] && ENABLE_ACL='mod'
#[[ $ENABLE_ARGON2 =~ (yes|mod) ]] && WITH_ARGON2='yes'

# Configurazione pre-installazione ed installazione di OpenLDAP

tput clear

printf "\n$(tput setaf 1)$(tput bold)%s$(tput sgr0)\n\n" "Installazione di OpenLDAP ${OPENLDAP_VERSION}"
cd ${EXTRACTION_PATH}

declare COMMAND_TO_RUN='./configure'

[[ ! $CONFIGURATION == 'Base' ]] && COMMAND_TO_RUN+=" \
		--enable-debug=$ENABLE_DEBUG \
		--enable-dynamic=$ENABLE_DYNAMIC \
		--enable-syslog=$ENABLE_SYSLOG \
		--enable-ipv6=$ENABLE_IPV6 \
		--enable-local=$ENABLE_LOCAL \
		--enable-slapd=$ENABLE_SLAPD \
		--enable-dynacl=$ENABLE_DYNACL \
		--enable-aci=$ENABLE_ACI \
		--enable-cleartext=$ENABLE_CLEARTEXT \
		--enable-crypt=$ENABLE_CRYPT \
		--enable-spasswd=$ENABLE_SPASSWD \
		--enable-modules=$ENABLE_MODULES \
		--enable-rlookups=$ENABLE_RLOOKUPS \
		--enable-slapi=$ENABLE_SLAPI \
		--enable-slp=$ENABLE_SLP \
		--enable-wrappers=$ENABLE_WRAPPERS \
		--enable-backends=$ENABLE_BACKENDS \
		--enable-dnssrv=$ENABLE_DNSSRV \
		--enable-ldap=$ENABLE_LDAP \
		--enable-mdb=$ENABLE_MDB \
		--enable-meta=$ENABLE_META \
		--enable-asyncmeta=$ENABLE_ASYNCMETA \
		--enable-null=$ENABLE_NULL \
		--enable-passwd=$ENABLE_PASSWD \
		--enable-perl=$ENABLE_PERL \
		--enable-relay=$ENABLE_RELAY \
		--enable-sock=$ENABLE_SOCK \
		--enable-sql=$ENABLE_SQL \
		--enable-wt=$ENABLE_WT \
		--enable-overlays=$ENABLE_OVERLAYS \
		--enable-accesslog=$ENABLE_ACCESSLOG \
		--enable-auditlog=$ENABLE_AUDITLOG \
		--enable-autoca=$ENABLE_AUTOCA \
		--enable-collect=$ENABLE_COLLECT \
		--enable-constraint=$ENABLE_CONSTRAINT \
		--enable-dds=$ENABLE_DDS \
		--enable-deref=$ENABLE_DEREF \
		--enable-dyngroup=$ENABLE_DYNGROUP \
		--enable-dynlist=$ENABLE_DYNLIST \
		--enable-homedir=$ENABLE_HOMEDIR \
		--enable-memberof=$ENABLE_MEMBEROF \
		--enable-otp=$ENABLE_OTP \
		--enable-ppolicy=$ENABLE_PPOLICY \
		--enable-proxycache=$ENABLE_PROXYCACHE \
		--enable-refint=$ENABLE_REFINT \
		--enable-rwm=$ENABLE_RWM \
		--enable-seqmod=$ENABLE_SEQMOD \
		--enable-sssvlv=$ENABLE_SSSVLV \
		--enable-syncprov=$ENABLE_SYNCPROV \
		--enable-translucent=$ENABLE_TRANSLUCENT \
		--enable-unique=$ENABLE_UNIQUE \
		--enable-valsort=$ENABLE_VALSORT \
		--with-argon2=$WITH_ARGON2 \
		--enable-argon2=$ENABLE_ARGON2 \
		--enable-balancer=$ENABLE_BALANCER \
		--with-cyrus-sasl=$WITH_CYRUS \
		--with-systemd=$WITH_SYSTEMD \
		--with-fetch=$WITH_FETCH \
		--with-threads=$WITH_THREADS \
		--with-tls=$WITH_TLS \
		--with-yielding-select=$WITH_YIELDINGSELECT \
		--with-mp=$WITH_MP \
		--with-odbc=$WITH_ODBC \
		--with-aix-soname=$WITH_AIXSONAME \
		--with-gnu-ld=$WITH_GNULD"

declare CONFIGURATION_BACKUP_FILE="last_configuration.sh"

[[ -f $CONFIGURATION_BACKUP_FILE ]] || touch $CONFIGURATION_BACKUP_FILE
chmod +x $CONFIGURATION_BACKUP_FILE

echo $COMMAND_TO_RUN > $CONFIGURATION_BACKUP_FILE

${COMMAND_TO_RUN}

printf "%s\n" "Procedere all'installazione di OpenLDAP ${OPENLDAP_VERSION}?"
select GO_ON in 'no' 'yes';
do
	if [[ $GO_ON == 'yes' ]];
	then

		make depend && make && make install

		cd ..

		tput clear

		printf "\n$(tput setaf 1)$(tput bold)%s$(tput sgr0)\n\n" "Creazione degli utenti e dei percorsi necessari"

		# Creazione dell'utente di esercizio del server SLAPd
		printf "\n$(tput setaf 1)$(tput bold)%s$(tput sgr0)\n\n" "Creazione dell'utente slpad"
		[[ -z $(grep -E '^slapd:' /etc/passwd) ]] && useradd slapd && printf "$(tput bold)%s$(tput sgr0)\n" "Fatto!"

		# Definizione dei percorsi utilizzati da OpenLDAP e dai suoi demoni
		declare BASE_DIR='/usr/local'
		declare CONF_DIR='/usr/local/etc/openldap'
		declare SLAPD_CONF_FILE=${CONF_DIR}'/slapd.conf'
		declare LDAP_CONF_FILE=${CONF_DIR}'/ldap.conf'
		declare SLAPDD_CONF_DIR='/usr/local/etc/openldap/slapd.d'
		declare SCHEMA_DIR='/usr/local/etc/openldap/schema'
		declare RUN_DIR='/usr/local/var/run'
		declare RUN_SLAPD_DIR='/usr/local/var/run/slapd'
		declare LIB_DIR='/usr/local/libexec/openldap'
		declare LDAP_BIN='/usr/local/bin/ldap'
		declare SLAPD_BIN='/usr/local/sbin/slapd'
		declare DB_DIR='/usr/local/var/openldap-data'
		declare MODULES_DIR='/usr/local/libexec/openldap'
		declare SLAPD_ENV_FILE='/etc/sysconfig/slapd'
		declare SLAPD_SERVICE_PATH='/usr/lib/systemd/system/slapd.service'

		[[ -z $(grep -E --regexp='^PATH=([a-zA-Z0-9_]+:)*'${LDAP_BIN}'($|:[a-zA-Z0-9_]+)' /$(whoami)/.bashrc) ]] && echo "export PATH=${LDAP_BIN}:$PATH" >> /$(whoami)/.bashrc

		[[ -z $(grep -E --regexp='^PATH=([a-zA-Z0-9_]+:)*'${SLAPD_BIN}'($|:[a-zA-Z0-9_]+)' /$(whoami)/.bashrc) ]] && echo "export PATH=${SLAPD_BIN}:$PATH" >> /$(whoami)/.bashrc

		# Creazione della directory di configurazione di slapd.d ed attribuzione dei privilegi di accesso corretti
		printf "\n$(tput setaf 1)$(tput bold)%s$(tput sgr0)\n\n" "Creazione della directory di configurazione di slapd.d ed attribuzione dei privilegi corretti"
		([[ -d $SLAPDD_CONF_DIR ]] || mkdir $SLAPDD_CONF_DIR) && chown slapd:root $SLAPDD_CONF_DIR && chmod +rwx $SLAPDD_CONF_DIR && printf "$(tput bold)%s$(tput sgr0)\n" "Fatto!"

		# Creazione dei link simbolici ai files e alla directory di configurazione
		ln -s /usr/local/etc/openldap/slapd.conf /etc/openldap/
		ln -s /usr/local/etc/openldap/slapd.d /etc/openldap/
		chown slapd:root /etc/openldap/slapd.*

		# Creazione della directory del database ed attribuzione dei privilegi di accesso corretti
		printf "\n$(tput setaf 1)$(tput bold)%s$(tput sgr0)\n\n" "Creazione della directory del Database ed attribuzione dei privilegi corretti"
		([[ -d $DB_DIR ]] || mkdir $DB_DIR) && chown slapd:root $DB_DIR && chmod +rw $DB_DIR && printf "$(tput bold)%s$(tput sgr0)\n" "Fatto!"

		# Attribuzione dei privilegi corretti alla directory di esercizio
		printf "\n$(tput setaf 1)$(tput bold)%s$(tput sgr0)\n\n" "Creazione della directory di esercizio ed attribuzione dei privilegi corretti"
		([[ -d ${RUN_DIR} ]] || mkdir ${RUN_DIR}) && chown slapd:root ${RUN_DIR} && chmod 664 ${RUN_DIR} && printf "$(tput bold)%s$(tput sgr0)\n" "Fatto!"

		# Creazione della directory di esercizio di SLAPd e attribuzione dei privilegi corretti
		printf "\n$(tput setaf 1)$(tput bold)%s$(tput sgr0)\n\n" "Creazione della directory di esercizio del demone SLAPd ed attribuzione dei privilegi corretti"
		([[ -d ${RUN_SLAPD_DIR} ]] || mkdir ${RUN_SLAPD_DIR}) && chown slapd:root ${RUN_SLAPD_DIR} && chmod 550 ${RUN_SLAPD_DIR} && printf "$(tput bold)%s$(tput sgr0)\n" "Fatto!"

		# Creazione del file di ambiente
		printf "\n$(tput setaf 1)$(tput bold)%s$(tput sgr0)\n\n" "Creazione del file di ambiente"
		[[ -f $SLAPD_ENV_FILE ]] || (touch $SLAPD_ENV_FILE && printf "$(tput bold)%s$(tput sgr0)\n" "Fatto!")

		# Modifica del file di avvio tramite SystemD e riavvio del demone SystemD
		printf "\n$(tput setaf 1)$(tput bold)%s$(tput sgr0)\n\n" "Modifica del file di avvio tramite SystemD"
		if [[ $WITH_SYSTEMD == 'yes'  && -f ${SLAPD_SERVICE_PATH} ]];
		then

			sed -Ei'.old' 's/(^ExecStart=\/usr\/local\/libexec\/slapd -d 0 -h \$\{SLAPD_URLS\} \$SLAPD_OPTIONS$)/#\1/' ${SLAPD_SERVICE_PATH}
			sed -Ei'.old' '/#ExecStart=\/usr\/local\/libexec\/slapd -d 0 -h \$\{SLAPD_URLS\} \$SLAPD_OPTIONS/a ExecStart=/usr/local/libexec/slapd -d 0 -s any -h ${SLAPD_URLS} $SLAPD_OPTIONS' ${SLAPD_SERVICE_PATH}
			systemctl daemon-reload
			printf "$(tput bold)%s$(tput sgr0)\n" "Fatto!"
		else
			printf "$(tput bold)%s$(tput sgr0)\n" "Il supporto per SystemD non è abilitato"
		fi
		

		# Attribuzione dei privilegi corretti alla directory di configurazione
		printf "\n$(tput setaf 1)$(tput bold)%s$(tput sgr0)\n\n" "Attribuzione dei privilegi corretti alla directory di configurazione"
		chown slapd:root ${CONF_DIR}
		printf "$(tput bold)%s$(tput sgr0)\n" "Fatto!"

		# Backup e sostituzione dei file di configurazione di SLAPd e LDAP
		printf "\n$(tput setaf 1)$(tput bold)%s$(tput sgr0)\n\n" "Impostazione del file di configurazione del demone SLAPd"
		[[ -f ${SLAPD_CONF_FILE} ]] && cp ${SLAPD_CONF_FILE} ${SLAPD_CONF_FILE}'.original'
		[[ -f './slapd.conf' ]] && cp -f './slapd.conf' ${CONF_DIR}
		chown slapd:root ${SLAPD_CONF_FILE}
		chmod 664 ${SLAPD_CONF_FILE}
		printf "$(tput bold)%s$(tput sgr0)\n" "Fatto!"

		printf "\n$(tput setaf 1)$(tput bold)%s$(tput sgr0)\n\n" "Impostazione del file di configurazione del client LDAP"
		[[ -f ${LDAP_CONF_FILE} ]] && cp ${LDAP_CONF_FILE} ${LDAP_CONF_FILE}'.original'
		[[ -f '.ldap.conf' ]] && cp -f '.ldap.conf' ${CONF_DIR}
		chown slapd:root ${LDAP_CONF_FILE}
		chmod 664 ${LDAP_CONF_FILE}
		printf "$(tput bold)%s$(tput sgr0)\n" "Fatto!"

		## Definizione del ruolo del server OpenLDAP in un'architettura di replica
		#printf "\n%s\n" "Definire il ruolo del server OpenLDAP in un'architettura di replica?"
		#select SERVER_ROLE in 'Master' 'Slave' 'Nessuno';
		#do
		#	case $SERVER_ROLE in
		#		Master)
		#			echo "include /usr/local/etc/openldap/includes/testmaster1.conf" >> ${SLAPD_CONF_FILE}
		#		;;
		#		Slave)
		#			echo "include /usr/local/etc/openldap/includes/testmaster1.conf" >> ${SLAPD_CONF_FILE}
		#		;;
		#		Nessuno)
		#		;;
		#	esac
		#	break
		#done
		#printf "$(tput bold)%s$(tput sgr0)\n" "Fatto!"
		#
		
		## Creazione del percorso di inclusione automatica dei file di configurazione del demone
		#printf "\n$(tput setaf 1)$(tput bold)%s$(tput sgr0)\n\n" "Creazione del percorso di inclusione automatica dei file di configurazione del demone"
		#
		#declare INCLUDES_DIR=${CONF_DIR}'/includes'
		#
		#[[ -d ${INCLUDES_DIR} ]] || mkdir ${INCLUDES_DIR}
		#chown slapd:root ${INCLUDES_DIR}
		#chmod 664 ${INCLUDES_DIR}
		#printf "$(tput bold)%s$(tput sgr0)\n" "Fatto!"
		#
		## Creazione del file di configurazione per i test del RSIS C4
		#printf "\n$(tput setaf 1)$(tput bold)%s$(tput sgr0)\n\n" "Creazione del file di configurazione per i test del RSIS C4"
		#
		#declare -a RSISC4_CONF_TEST_FILES=("testmaster1.conf" "testslave1.conf")
		#
		#for RSISC4_CONF_TEST_FILE in ${RSISC4_CONF_TEST_FILES[@]};
		#do
		#	([[ -f ${RSISC4_CONF_TEST_FILE} ]] && cp ${RSISC4_CONF_TEST_FILE} ${INCLUDES_DIR}) && chown slapd:root ${INCLUDES_DIR}'/'${RSISC4_CONF_TEST_FILE} && chmod 664 ${INCLUDES_DIR}'/'${RSISC4_CONF_TEST_FILE}
		#done
		#printf "$(tput bold)%s$(tput sgr0)\n" "Fatto!"
		
		# Avvio del demone SLAPd
		printf "$(tput setaf 1)$(tput bold)%s$(tput sgr0)\n\n" "Avvio del demone SLAPd"
		printf "%s\n" "Si desidera $(tput bold)avviare il demone SLAPd$(tput sgr0)?"
		OPTIONS=('No' 'Sì')
		select START_DAEMON in ${OPTIONS[@]};
		do
			if [[ $START_DAEMON == 'Sì' ]];
			then
				if [[ $WITH_SYSTEMD == 'yes' ]];
				then
					systemctl daemon-reload && systemctl start slapd && printf "$(tput bold)%s$(tput sgr0)\n" "Fatto!"

					printf "%s\n" "Abilitare $(tput bold)permanentemente$(tput sgr0) l'esecuzione del demone SLAPd $(tput bold)ad ogni riavvio del sistema$(tput sgr0)?"
					select START_ON_BOOT in ${OPTIONS[@]};
					do
						[[ ${START_ON_BOOT} == 'Sì' ]] && systemctl enable slapd && printf "$(tput bold)%s$(tput sgr0)\n" "Fatto!"
						break
					done
				else
					[[ ! -f ${RUN_DIR}'/slapd.pid' ]] && /usr/local/libexec/slapd -d any -s any -f /usr/local/etc/openldap/slapd.conf -F /usr/local/etc/openldap/slapd.d/  && printf "$(tput bold)%s$(tput sgr0)\n" "Fatto!" || printf "%s\n" "Il demone SLAPd è $(tput bold)già in esecuzione$(tput sgr0)"
				fi
			fi
			break
		done

		exit 0

	else
		exit 1
	fi
	break
done
