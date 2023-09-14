#!/bin/bash

ARGS="-Xmx6G -Xms2G -- -servername da-hood -cachedir=$DATA_DIR"

if [ -n "$ADMIN_PASSWORD" ]; then
	ARGS="$ARGS -adminpassword $ADMIN_PASSWORD"
fi


echo $ARGS

# Fix to a bug in start-server.sh that causes to no preload a library:
# ERROR: ld.so: object 'libjsig.so' from LD_PRELOAD cannot be preloaded (cannot open shared object file): ignored.
export LD_LIBRARY_PATH="${STEAMAPPDIR}/jre64/lib:${LD_LIBRARY_PATH}"
bash $APP_DIR/start-server.sh $ARGS
