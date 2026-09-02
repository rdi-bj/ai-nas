#!/bin/sh
#
# Start es bmc daemon
# bind ttyBMC irq to cpu1~cpu3 since cpu0 is busy
#

case "$1" in
	start)
		echo "Starting eswin bmc daemon..."
		/usr/bin/es-bmcd

		# Attempt to find the IRQ number for ttyBMC by matching 'PLIC 102 Edge'
		MAX_WAIT=3
		WAIT_INTERVAL=0.5
		WAITED=0
		IRQ=""

		# Search for the IRQ number associated with 'PLIC 102 Edge' (ttyBMC's interrupt source)
		while [ -z "$IRQ" ] && [ $(echo "$WAITED < $MAX_WAIT" | bc) -eq 1 ]; do
			# Get the IRQ number for 'PLIC 102 Edge' in /proc/interrupts
			IRQ=$(grep "PLIC 102 Edge" /proc/interrupts | awk '{print $1}' | sed 's/://')
			if [ -n "$IRQ" ]; then
				break
			fi
			sleep $WAIT_INTERVAL
			WAITED=$(echo "$WAITED + $WAIT_INTERVAL" | bc)
		done

		# Set IRQ affinity if IRQ was found
		if [ -n "$IRQ" ]; then
			# Set the IRQ affinity to CPUs 1, 2, and 3 (i.e., exclude CPU 0)
			echo e > /proc/irq/$IRQ/smp_affinity
			echo "[es_bmc_daemon][INFO] IRQ for ttyBMC ($IRQ) affinity set to cpu1-cpu3."
		else
			echo "[es_bmc_daemon][INFO] IRQ for ttyBMC not found after waiting $MAX_WAIT seconds."
		fi
		;;
	stop)
		echo "Stopping eswin bmc daemon..."
		pkill "es-bmcd"
		if [ $? -eq 0 ]; then
			echo "eswin bmc daemon stopped successfully."
		else
			echo "Failed to stop eswin bmc daemon."
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

