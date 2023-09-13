#!/usr/bin/env zsh

declare -A project_times
# declare -A project_total_times
CSV_FILE="timetracker.csv"
highest_index=0

# Function to read data from CSV file
function read_csv_data {
  if [[ -f "$CSV_FILE" ]]; then
    csvcut -c index,project,start_time,stop_time "$CSV_FILE"
  fi
}

# U+10348
# function to display prompt
## -n is a test operator. true if length of string is non-zero. -z true if length is zero
function set_prompt {
  if [[ -n $project ]]; then
    echo -n "\U10348 -> [$project] "
  else
    echo -n "\U10348 -> [ ] "
  fi
}

# Function to write data to the CSV file
function write_csv_data {
  index=$((highest_index + 1))
  echo "$index,$project,$start_time,$stop_time" >> "$CSV_FILE"
  (( index++ ))
}

# Load existing data from CSV file, if it exists
IFS=,
while read -r index project start_time stop_time; do
  project_times["$index:$project"]=$start_time
  # project_total_times["$index:$project"]=$stop_time
  if  [[ (( index > highest_index )) ]] ; then
    highest_index=$index
  fi
done < <(read_csv_data)
unset IFS

function cmd_print {
  echo "Total time spent on $project: seconds."
}

function cmd_quit {
  echo "Exiting..."
  exit 0
}




# Initialize the program
echo "Time Tracker"

# Process user commands
while true; do
  echo "Enter project name (-p project) or 'quit': "
  set_prompt
  read command

  if [[ "$command" == "quit" ]]; then
    cmd_quit
  elif [[ "$command" =~ ^-p ]]; then
    project=${command#-p }  # Extract project name from input
    echo "To begin work on $project, enter 'start'"
    set_prompt
    read start_input

    if [[ "$start_input" == "start" ]]; then
      start_time=$(date -u +%s)
      project_times["$project"]=$start_time
      # echo "Started tracking work on $project. start time is $start_time. project start times array is ${project_times["$project"]}"
    fi
  elif [[ "$command" == "print" ]]; then
    cmd_print
  else
    echo "Invalid input."
    set_prompt
  fi
  

  echo "Enter 'stop' to stop work on $project, or 'print' to print time: "
  set_prompt
  read stop_input

  if [[ "$stop_input" == "stop" ]]; then
    if [[ -n ${project_times["$project"]} ]]; then
      stop_time=$(date -u +%s)
      echo "Stopped tracking work on $project."
      write_csv_data
      echo "written to timetracker.csv"
    else
      echo "No active tracking found for $project."
    fi
  elif [[ "$stop_input" == "print" ]]; then
    echo "Total time spent on $project: ${project_total_times["$project"]} seconds."
    set_prompt
  else
    echo "Invalid input."
    set_prompt
  fi
done