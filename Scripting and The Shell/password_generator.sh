#!/bin/bash

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
RESET='\033[0m'

success() { echo -e "${GREEN}[SUCCESS] $*${RESET}"; }
error() { echo -e "${RED}[ERROR] $*${RESET}" >&2; }
info() { echo -e "${BLUE}$*${RESET}"; }

USAGE="\nUsage: $0 -l <length> [-a] [-n] [-s]

Options:
	-l, --length     Password length (minimum 8)
	-a, --alpha      Include alphabetic characters (a-z A-Z)
	-n, --numeric    Include numeric characters (0-9)
	-s, --special    Include special characters\n"

LENGTH=16
ALPHA=0
NUMERIC=0
SPECIAL=0

POOL_ALPHA="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
POOL_NUMERIC="0123456789"
POOL_SPECIAL="!@#$%^&*()-_=+[]{}|;:,.<>?"

parse_args()
{
	OPTS=$(getopt -o l:ansh -l length:,alpha,numeric,special,help -- "$@")
	[ $? -ne 0 ] && { info "$USAGE"; exit 1; }
	eval set -- "$OPTS"

	while true; do
		case "$1" in
			-l|--length)  LENGTH=$2; shift 2 ;;
			-a|--alpha)   ALPHA=1;   shift   ;;
			-n|--numeric) NUMERIC=1; shift   ;;
			-s|--special) SPECIAL=1; shift   ;;
			-h|--help)    info "$USAGE"; exit 0 ;;
			--) shift; break ;;
			*) info "$USAGE"; exit 1 ;;
		esac
	done
}

validate_inputs()
{
	if [[ ! $LENGTH =~ ^[0-9]+$ ]] || [ "$LENGTH" -lt 8 ]; then
		error "Password length must be at least 8 characters for security"
		exit 1
	fi

	if [ $ALPHA -eq 0 ] && [ $NUMERIC -eq 0 ] && [ $SPECIAL -eq 0 ]; then
		error "At least one character type must be selected (-a, -n, or -s)"
		exit 1
	fi

	CHARSET=""
	[ $ALPHA -eq 1 ] && CHARSET+=$POOL_ALPHA
	[ $NUMERIC -eq 1 ] && CHARSET+=$POOL_NUMERIC
	[ $SPECIAL -eq 1 ] && CHARSET+=$POOL_SPECIAL
}

generate_password()
{
	local selected_pools=()
	[ $ALPHA -eq 1 ] && selected_pools+=("$POOL_ALPHA")
	[ $NUMERIC -eq 1 ] && selected_pools+=("$POOL_NUMERIC")
	[ $SPECIAL -eq 1 ] && selected_pools+=("$POOL_SPECIAL")

	local num_types=${#selected_pools[@]}

	PASSWORD=""

	for pool in "${selected_pools[@]}"; do
		PASSWORD+=${pool:$((RANDOM % ${#pool})):1}
	done

	local remaining=$((LENGTH - num_types))
	for ((i = 0; i < remaining; i++)); do
		PASSWORD+=${CHARSET:$((RANDOM % ${#CHARSET})):1}
	done

	PASSWORD=$(echo "$PASSWORD" | fold -w1 | shuf | tr -d '\n')
}

main()
{
	parse_args "$@"
	validate_inputs
	generate_password
	success "$PASSWORD"
}

main "$@"
