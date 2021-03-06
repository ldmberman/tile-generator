#!/bin/sh -e

TILE_DIR="$( cd "$1" && pwd )"
POOL_DIR="$( cd "$2" && pwd )"
BACKUP_DIR="$( cd "$3" && pwd )"

MY_DIR="$( cd "$( dirname "$0" )" && pwd )"
REPO_DIR="$( cd "${MY_DIR}/../.." && pwd )"
BASE_DIR="$( cd "${REPO_DIR}/.." && pwd )"
BIN_DIR="$( cd "${REPO_DIR}/bin" && pwd )"

PCF="${BIN_DIR}/pcf"

PCF_NAME=`cat "${POOL_DIR}/name"`
if [ -z "${PCF_NAME}" ]; then
	echo "No pcf environment has been claimed"
	exit 1
fi

BACKUP_FILE="pcf-backup-${PCF_NAME}-0.0.1.yml"

TILE_FILE=`cd "${TILE_DIR}"; ls *.pivotal`
if [ -z "${TILE_FILE}" ]; then
	echo "No files matching ${TILE_DIR}/*.pivotal"
	ls -lR "${TILE_DIR}"
	exit 1
fi

PRODUCT=`echo "${TILE_FILE}" | sed "s/-[^-]*$//"`
VERSION=`echo "${TILE_FILE}" | sed "s/.*-//" | sed "s/\.pivotal\$//"`

cd "${POOL_DIR}"

echo "Available products:"
$PCF products
echo

if $PCF is-available "${PRODUCT}" ; then
	echo "Deleting unused products"
	$PCF delete-unused-products
	echo

	echo "Available products:"
	$PCF products
	echo
fi

if ! $PCF is-installed "${PRODUCT}" ; then
	echo "It appears that ${PRODUCT} was successfully removed - skipping restore"
	echo
	exit 0
fi

echo "Restoring from ${BACKUP_FILE}"
$PCF restore "${BACKUP_DIR}/${BACKUP_FILE}"
echo

echo "Available products:"
$PCF products
echo
