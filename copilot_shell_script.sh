#!/usr/bin/bash

# Enabling 'set -e' to ensure that the script will exit immediately if any command fails.
set -e

# Prompt the user for the name they used when creating the environment.
# This is necessary to locate the correct application directory ('submission_reminder_{userName}').
read -p "Please enter the name you used when creating the application environment (e.g., Hervé): " ENV_USER_NAME

# Construct the path to the main app directory by appending the user-provided name.
# This directory should have been created by 'create_environment.sh'.
MAIN_APP_DIR="submission_reminder_${ENV_USER_NAME}"

# Check if the main application directory exists.
# If it doesn't exist, notify the user and exit the script.
if [ ! -d "$MAIN_APP_DIR" ]; then
    echo "Error: The application directory '$MAIN_APP_DIR' was not found."
    echo "Please ensure you run this script from the same location where 'create_environment.sh' created your app."
    exit 1
fi

# Define the path to the 'config.env' file inside the 'config' subdirectory of the main app directory.
CONFIG_FILE="${MAIN_APP_DIR}/config/config.env"

# Check if the 'config.env' file exists.
# If it doesn't exist, notify the user and exit the script.
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: The configuration file '$CONFIG_FILE' was not found."
    echo "Please ensure the environment was set up correctly by 'create_environment.sh'."
    exit 1
fi

# Prompt the user to enter the new assignment name.
read -p "Hello, what is the new assignment name: " ASSIGNMENT_NAME

# --- Update the ASSIGNMENT value in config/config.env ---
# We use 'sed' to replace the current assignment value with the new one in 'config/config.env'.
# This operation updates the second line of the file, where the ASSIGNMENT variable is stored.
# Explanation of the 'sed' command:
# - '2s' means apply the substitution command to the second line of the file.
# - '^ASSIGNMENT=.*' is a regular expression that matches the line starting with 'ASSIGNMENT=' and any characters following it.
# - 'ASSIGNMENT=\"${ASSIGNMENT_NAME}\"' is the replacement text, where the value of 'ASSIGNMENT_NAME' is inserted.
#   Using double quotes around the replacement value ensures that multi-word assignment names are handled correctly.
sed -i "2s|^ASSIGNMENT=.*|ASSIGNMENT=\"${ASSIGNMENT_NAME}\"|" "$CONFIG_FILE"

# Confirmation message to indicate that the assignment name has been successfully updated in 'config.env'.
echo "Success! The 'ASSIGNMENT' in '$CONFIG_FILE' has been updated to: $ASSIGNMENT_NAME"

# --- Run startup.sh ---
# After updating the assignment, we need to rerun 'startup.sh' to check the non-submission status for the new assignment.
# We change into the main application directory before running 'startup.sh' to ensure it runs in the correct context.
echo "Now running startup.sh to check student submission status for '$ASSIGNMENT_NAME'..."
cd "$MAIN_APP_DIR" && "./startup.sh"

# Final message indicating the script has finished execution.
echo "Script finished."
