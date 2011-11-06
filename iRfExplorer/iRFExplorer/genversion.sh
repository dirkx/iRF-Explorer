#!/bin/sh
FILE=${1:-${PRODUCT_NAME}/revision.h}

V=$(/usr/bin/svnversion)
T=$(TZ=UTV date +%Y/%m/%d.%TZ)

cat > "${FILE}" <<EOM
// Warning - generated. Do not edit.
//
#define REVISION "$V"
#define	BUILDON "$T"
// const char * revision[] = "$V";
EOM
