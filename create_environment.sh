#!/usr/bin/bash

# Enabling the 'set -e' option ensures that the script will exit if any command fails.
set -e 

# Prompt the user for their name and store it in the variable 'NAME'.
# The name entered will later be used to create a personalized folder for the project.
read -p "Hello, enter your name please " NAME

# Creating a base directory to hold all files related to the submission reminder app.
# The folder is named using the user's input to make it personalized.
mkdir submission_reminder_$NAME

# Creating the main directories within the project for organizing files:
# - 'app' for core application scripts
# - 'modules' for helper functions
# - 'assets' for required static files (e.g., the submissions list)
# - 'config' for configuration settings like environment variables.
mkdir submission_reminder_$NAME/app
mkdir submission_reminder_$NAME/modules
mkdir submission_reminder_$NAME/assets
mkdir submission_reminder_$NAME/config

# Instead of copying pre-existing files, which may not work for others, we will generate the necessary files directly within the script.
# This ensures that the setup is flexible for any user.
cd submission_reminder_$NAME

# Creating and populating 'reminder.sh' file:
# This is the main script that prints a reminder for submissions and calls helper functions.
cat << 'EOF_REMINDER' > app/reminder.sh
#!/usr/bin/bash
echo "This is the reminder app running"
# Source configuration and function files to set up environment and helper functions.
source ./config/config.env
source ./modules/functions.sh
# Define the path to the submissions file which contains the list of student submissions.
submissions_file="./assets/submissions.txt"
# Output assignment information and the number of days left to submit.
echo "Assignment: $ASSIGNMENT"
echo "Days remaining to submit: $DAYS_REMAINING days"
echo "--------------------------------------------"
# Call the function to check the status of student submissions.
check_submissions $submissions_file
EOF_REMINDER

# Creating and populating 'functions.sh' file:
# This file contains a function to process the submissions file and print reminders for students who haven't submitted their assignment.
cat << 'EQF_FUNCTIONS' > modules/functions.sh
#!/usr/bin/bash
# Function to read the submissions file and output students who have not submitted their assignment.
function check_submissions {
    local submissions_file=$1
    echo "Checking submissions in $submissions_file"

    # Skip the header and iterate through each line in the file.
    while IFS=, read -r student assignment status; do
        # Trim whitespace from the student name, assignment, and status.
        student=$(echo "$student" | xargs)
        assignment=$(echo "$assignment" | xargs)
        status=$(echo "$status" | xargs)

        # Check if the current assignment is the one we're tracking and if the submission status is 'not submitted'.
        if [[ "$assignment" == "$ASSIGNMENT" && "$status" == "not submitted" ]]; then
            echo "Reminder: $student has not submitted the $ASSIGNMENT assignment!"
        fi
    done < <(tail -n +2 "$submissions_file") # Skip the header line in the file.
}

EQF_FUNCTIONS

# Creating and populating 'submissions.txt' with an example list of students and their submission statuses.
# This will help test the app's functionality.
cat << EQF_SUBMISSIONS > assets/submissions.txt
student, assignment, submission status
Chinemerem, Shell Navigation, not submitted
Chiagoziem, Git, submitted
Divine, Shell Navigation, not submitted
Anissa, Shell Basics, submitted
EQF_SUBMISSIONS

# Creating the 'config.env' file to store the assignment name and the number of days left for submission.
cat << EQF_CONFIG > config/config.env
# This is the config file for storing environment variables.
ASSIGNMENT="Shell Navigation"
DAYS_REMAINING=2
EQF_CONFIG

cd ..

# Appending additional student records to 'submissions.txt' for testing the app with a larger dataset.
echo "Kofi, Git, submitted" >> submission_reminder_$NAME/assets/submissions.txt
echo "Lena, Shell Basics, not submitted" >> submission_reminder_$NAME/assets/submissions.txt
echo "Malik, Shell Navigation, not submitted" >> submission_reminder_$NAME/assets/submissions.txt
echo "Sena, Git, submitted" >> submission_reminder_$NAME/assets/submissions.txt
echo "Juma, Shell Basics, not submitted" >> submission_reminder_$NAME/assets/submissions.txt
echo "Nia, Emacs, not submitted" >> submission_reminder_$NAME/assets/submissions.txt
echo "Tariq, vi, submitted" >> submission_reminder_$NAME/assets/submissions.txt
echo "Zara, vi, submitted" >> submission_reminder_$NAME/assets/submissions.txt
echo "Amara, Git, not submitted" >> submission_reminder_$NAME/assets/submissions.txt
echo "Bayo, Shell Navigation, submitted" >> submission_reminder_$NAME/assets/submissions.txt
echo "Imani, Shell Basics, not submitted" >> submission_reminder_$NAME/assets/submissions.txt
echo "Khadim, Shell Navigation, not submitted" >> submission_reminder_$NAME/assets/submissions.txt
echo "Fatima, Git, not submitted" >> submission_reminder_$NAME/assets/submissions.txt

# Creating the 'startup.sh' script which is used to initialize the reminder app.
# It sources the required configuration and function files, then launches the reminder app.
cat <<EOF > submission_reminder_$NAME/startup.sh
#!/bin/bash
# 'source' is used to load the content of config.env and functions.sh into the current shell session.
source ./config/config.env
source ./modules/functions.sh
# 'bash' is used to run the reminder.sh script in a new subshell.
bash ./app/reminder.sh
EOF

# Making all the shell script files executable using the 'chmod +x' command.
# This ensures the user can run the scripts directly.
find submission_reminder_$NAME -type f -name "*.sh" -exec chmod +x {} \;
