#!/bin/sh
#
# Start eswin thermal daemon
#

# Define PID file path (consistent with es-thermald.service file).
PARENT_PID_FILE="/run/es-thermald-parent.pid"
CHILD_PID_FILE="/run/es-thermald-child.pid"

case "$1" in
	start)
		echo "Starting eswin thermal daemon..."
		if [ ! -f "$PARENT_PID_FILE" ]; then
			/usr/bin/es-thermald &
			timeout=3
			while [ ! -f "$PARENT_PID_FILE" ] && [ $timeout -gt 0 ]; do
				sleep 1
				timeout=$((timeout - 1))
			done
			if [ -f "$PARENT_PID_FILE" ]; then
				PID=$(cat "$PARENT_PID_FILE")
				if kill -0 "$PID" > /dev/null 2>&1; then
					echo "eswin thermal daemon started, parent pid is $PID"
				else
					echo "failed to start, parent pid $PID is not running"
					rm -f "$PARENT_PID_FILE"
					exit 1
				fi
			else
				echo "failed to start, parent pid file not created"
				exit 1
			fi
		else
			echo "eswin thermal daemon is already running, parent pid is $(cat $PARENT_PID_FILE)"
		fi
		;;

	stop)
		echo "Stopping eswin thermal daemon..."
		if [ -f "$PARENT_PID_FILE" ]; then
			# Read process id from PID file and terminate it.
			PID=$(cat "$PARENT_PID_FILE")
			kill -TERM "$PID"
			# Wait for the process to exit and delete the PID file.
			timeout=3
			while [ -f "$PARENT_PID_FILE" ] && kill -0 "$PID" > /dev/null 2>&1 && [ $timeout -gt 0 ]; do
				sleep 1
				timeout=$((timeout - 1))
			done
			if [ ! -f "$PARENT_PID_FILE" ] || ! kill -0 "$PID" > /dev/null 2>&1; then
				rm -f "$PARENT_PID_FILE" "$CHILD_PID_FILE"
				echo "eswin thermal daemon stopped successfully."
			else
				echo "force killing parent process..."
				kill -KILL "$PID"
				rm -f "$PARENT_PID_FILE" "$CHILD_PID_FILE"
			fi
		else
			# If the PID file does not exist, try terminating it with pkill.
			pkill -f 'es-thd-parent'
			if [ $? -eq 0 ]; then
				rm -f "$PARENT_PID_FILE" "$CHILD_PID_FILE"
				echo "eswin thermal daemon stopped successfully."
			else
				echo "eswin thermal daemon is not running."
			fi
		fi
		;;

	restart|reload)
		$0 stop
		$0 start
		;;
	*)
		echo "Usage: $0 {start|stop|restart}"
		exit 1
esac

exit $?

