#!/bin/bash

# Set an environment variable
export ENV_VAR="${env_var}"

# Execute user_data_users.sh
echo "Running user_data_users.sh..."
${script1}

# Execute user_data_logs.sh
echo "Running user_data_logs.sh..."
${script2}

# Execute user_data_apache.sh
echo "Running user_data_apache.sh..."
${script3}

# Execute user_data_cron
echo "Running user_data_cron.sh..."
${script4}
