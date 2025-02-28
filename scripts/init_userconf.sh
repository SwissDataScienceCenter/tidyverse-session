#!/usr/bin/with-contenv bash
# shellcheck shell=bash

## Set defaults for environmental variables in case they are undefined
DEFAULT_USER=${DEFAULT_USER:-rstudio}
USER=${DEFAULT_USER}
USERID=${USERID:=1000}
GROUPID=${GROUPID:=1000}
ROOT=${ROOT:=FALSE}
UMASK=${UMASK:=022}
LANG=${LANG:=en_US.UTF-8}
TZ=${TZ:=Etc/UTC}
USERHOME="/home/${USER}"

# Remove anything around RUNROOTLESS or anything that requires root, since we do not have it
# These are done in the Dockerfile
# if [[ ${DISABLE_AUTH,,} == "true" ]]; then
#     cp /etc/rstudio/disable_auth_rserver.conf /etc/rstudio/rserver.conf
#     echo "USER=$USER" >>/etc/environment
# fi

if grep --quiet "auth-none=1" /etc/rstudio/rserver.conf; then
    echo "Skipping authentication as requested"
elif [ -z "$PASSWORD" ]; then
    PASSWORD=$(pwgen 16 1)
    printf "\n\n"
    tput bold
    printf "The password is set to \e[31m%s\e[39m\n" "$PASSWORD"
    printf "If you want to set your own password, set the PASSWORD environment variable. e.g. run with:\n"
    printf "docker run -e PASSWORD=\e[92m<YOUR_PASS>\e[39m -p 8787:8787 rocker/rstudio\n"
    tput sgr0
    printf "\n\n"
fi

if [ "$USERID" -lt 1000 ]; then # Probably a macOS user, https://github.com/rocker-org/rocker/issues/205
    echo "$USERID is less than 1000"
    check_user_id=$(grep -F "auth-minimum-user-id" /etc/rstudio/rserver.conf)
    if [[ -n $check_user_id ]]; then
        echo "minimum authorised user already exists in /etc/rstudio/rserver.conf: $check_user_id"
    else
        echo "setting minimum authorised user to 499"
        echo auth-minimum-user-id=499 >>/etc/rstudio/rserver.conf
    fi
fi

## Add a password to user
# echo "$USER:$PASSWORD" | chpasswd

# This will not work, if you want to do this, need to do it in the Dockerfile
# # Use Env flag to know if user should be added to sudoers
# if [[ ${ROOT,,} == "true" ]]; then
#     adduser "$USER" sudo && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers
#     echo "$USER added to sudoers"
# fi

## Change Umask value if desired
if [ "$UMASK" -ne 022 ]; then
    echo "server-set-umask=false" >>/etc/rstudio/rserver.conf
    echo "Sys.umask(mode=$UMASK)" >>"${USERHOME}"/.Rprofile
fi

## Next one for timezone setup
if [ "$TZ" != "Etc/UTC" ]; then
    ln -snf /usr/share/zoneinfo/"$TZ" /etc/localtime && echo "$TZ" >/etc/timezone
fi

## Update Locale if needed
if [ "$LANG" != "en_US.UTF-8" ]; then
    /usr/sbin/locale-gen --lang "$LANG"
    /usr/sbin/update-locale --reset LANG="$LANG"
fi
