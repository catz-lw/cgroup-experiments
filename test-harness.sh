#!/bin/bash
set -eu

# Print the version of cgroups
stat -fc %T /sys/fs/cgroup/


# Create a new cgroup under the memory subsystem
CGROUP_NAME="memory_limit_100mb"
CGROUP_PATH="/sys/fs/cgroup/$CGROUP_NAME" # v2

# Remove group if it exists
sudo rmdir ${CGROUP_PATH} | :

# Print which controllers are enabled
echo subtree_control: $(cat /sys/fs/cgroup/cgroup.subtree_control)

# Create the cgroup directory
sudo mkdir -p ${CGROUP_PATH}
echo created cgroup ${CGROUP_PATH}
# sudo chown -R ${USER} ${CGROUP_PATH}

# Set the memory limit to 100MB (104857600 bytes)
echo 104857600 | sudo tee $CGROUP_PATH/memory.max              # v2
# echo 104857600 | sudo tee $CGROUP_PATH/memory.limit_in_bytes # v1

# Optional: Set a soft limit (just a guidance to the kernel)
# echo 52428800 > $CGROUP_PATH/memory.soft_limit_in_bytes

# Attach this scritpt's process to the cgroup, it will be killed as well along
# with the process that is created later in this script
echo $$ | sudo tee $CGROUP_PATH/cgroup.procs

# Run your command in the background
./touch-mem 90 &
pid0=$!
# Add the process to the cgroup
echo $pid0 | sudo tee $CGROUP_PATH/cgroup.procs
echo "added the first process to the cgroup"

# Run your command in the background
./touch-mem 90 &
pid1=$!
# Add the process to the cgroup
echo $pid1 | sudo tee $CGROUP_PATH/cgroup.procs
echo "added the second process to the cgroup"

sleep 2
kill -USR1 $pid0

sleep 2
kill -USR1 $pid1

# Wait for the process to finish
wait $pid0