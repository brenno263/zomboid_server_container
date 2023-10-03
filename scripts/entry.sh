#!/bin/bash

ARGS="-Xmx8G -Xms4G -- -servername da-hood -cachedir=$DATA_DIR"

if [ -n "$ADMIN_PASSWORD" ]; then
	ARGS="$ARGS -adminpassword $ADMIN_PASSWORD"
fi

echo "Using args: $ARGS"

# Set up our fifo pipe to push commands into the running server.
ZOMBOID_STDIN_PIPE="zomboid_stdin_pipe"
mkfifo "$ZOMBOID_STDIN_PIPE"

# Fix to a bug in start-server.sh that causes to no preload a library:
# ERROR: ld.so: object 'libjsig.so' from LD_PRELOAD cannot be preloaded (cannot open shared object file): ignored.
export LD_LIBRARY_PATH="${APP_DIR}/jre64/lib:${LD_LIBRARY_PATH}"

# Start the server, taking stdin from our pipe so that we can talk to it later.
# Notice that we don't redirect server outputs, so they still land in the terminal.
bash $APP_DIR/start-server.sh $ARGS 0<> "$ZOMBOID_STDIN_PIPE" &
SERVER_PID=$!
echo "THE PID OF THE SERVER IS $SERVER_PID!"

# Set QUIT to 1 when we get a SIGTERM or SIGINT, breaking the following sleep loop.
QUIT=0
trap "QUIT=1" TERM INT

# Loop until we've decided to quit or the server is somehow not running.
while [ "$QUIT" -eq "0" ] && kill -0 "$SERVER_PID" >& /dev/null ; do
	sleep 10;
	echo "sleeping"
	# If there's any input hanging out on stdin, go ahead and push it through the pipe.
	# This helps us maintain interactivity when running this script.
	if read -t 0 ; then
		echo "found stdin, writing to pipe."
		while read -r -t 0.5 line; do
			echo "writing $line"
			echo "$line" > "$ZOMBOID_STDIN_PIPE"
		done
	fi
done

# Once we've broken the sleep loop, send the quit command to the server and wait for it to stop.
echo "quitting"
echo "quit" > "$ZOMBOID_STDIN_PIPE"

echo "waiting"
wait # waits for child processes to complete

rm "$ZOMBOID_STDIN_PIPE"
echo "done"
