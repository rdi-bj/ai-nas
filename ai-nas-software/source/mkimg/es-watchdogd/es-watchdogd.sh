#!/bin/sh
#
# Start eswin watchdogd daemon
#

# Define PID file path (consistent with es-watchdogd.service file).
PID_FILE="/var/run/es-watchdogd.pid"

case "$1" in
	start)
		echo "Starting eswin watchdogd daemon..."
		if [ ! -f "$PID_FILE" ]; then
			/usr/bin/es-watchdogd &
			timeout=3
			while [ ! -f "$PID_FILE" ] && [ $timeout -gt 0 ]; do
				sleep 1
				timeout=$((timeout - 1))
			done
			if [ -f "$PID_FILE" ]; then
				PID=$(cat "$PID_FILE")
				if ps -p "$PID" > /dev/null; then
					echo "eswin watchdogd daemon started (PID: $PID)"
				else
					echo "Failed to start: PID $PID is not running"
					rm -f "$PID_FILE"
					exit 1
				fi
			else
				echo "Failed to start: PID file not created"
				exit 1
			fi
		else
			echo "eswin watchdogd daemon is already running (PID: $(cat $PID_FILE))"
		fi
		;;

	stop)
		echo "Stopping eswin watchdogd daemon..."
		if [ -f "$PID_FILE" ]; then
			# Read process id from PID file and terminate it.
			PID=$(cat "$PID_FILE")
			kill -TERM "$PID"
			# Wait for the process to exit and delete the PID file.
			timeout=3
			while [ -f "$PID_FILE" ] && ps -p "$PID" > /dev/null && [ $timeout -gt 0 ]; do
				sleep 1
				timeout=$((timeout - 1))
			done
			if [ ! -f "$PID_FILE" ] || ! ps -p "$PID" > /dev/null; then
				rm -f "$PID_FILE"
				echo "eswin watchdogd daemon stopped successfully."
			else
				echo "Failed to stop: force killing..."
				kill -KILL "$PID"
				rm -f "$PID_FILE"
			fi
		else
			# If the PID file does not exist, try terminating it with pkill.
			pkill -f '/usr/bin/es-watchdogd'
			if [ $? -eq 0 ]; then
				echo "eswin watchdogd daemon stopped successfully."
			else
				echo "eswin watchdogd daemon is not running."
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

