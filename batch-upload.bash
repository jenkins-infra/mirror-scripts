#!/bin/bash

#shellcheck disable=SC1091
source /srv/releases/.venv-blobxfer/bin/activate

#shellcheck disable=SC1091
source /srv/releases/.azure-storage-env
: "${AZURE_STORAGE_ACCOUNT?}" "${AZURE_STORAGE_KEY?}"

## Sync files from "/srv/releases/jenkins/$CONTAINER" to $CONTAINER for each container in "$AZURE_STORAGE_ACCOUNT",
for CONTAINER in $(az storage container list --account-name "${AZURE_STORAGE_ACCOUNT}" --account-key "${AZURE_STORAGE_KEY}" --query '[*].name' --output table ); do
	if [[ -d "/srv/releases/jenkins/${CONTAINER}" ]]; then
		echo "Syncing Container: ${CONTAINER}";

		time blobxfer upload \
			--local-path "/srv/releases/jenkins/${CONTAINER}/" \
			--storage-account-key "${AZURE_STORAGE_KEY}" \
			--storage-account "${AZURE_STORAGE_ACCOUNT}" \
			--remote-path "${CONTAINER}" \
			--recursive \
			--skip-on-lmt-ge \
			--connect-timeout 30 \
			--exclude '.htaccess'
		fi
done;
