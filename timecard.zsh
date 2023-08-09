#!/usr/bin/env zsh

typeset -A project_start_times
typeset -A project_total_times
CSV_FILE="timetracker.csv"

# Function to read data from CSV file
function read_csv_data {
  if [[ -f "$CSV_FILE" ]]; then
    csvcut -c project,start_time,stop_time "$CSV_FILE"
  fi
}

# Function to write data to the CSV file
function write_csv_data {
  echo "project,start_time,stop_time" > "$CSV_FILE"
  for project in ${(k)project_start_times}; do
    echo "$project,${project_start_times[$project]},${project_total_times[$project]}" >> "$CSV_FILE"
  done
}

# Load existing data from CSV file, if it exists
IFS=,
while read -r project start_time stop_time; do
  project_start_times["$project"]=$start_time
  project_total_times["$project"]=$stop_time
done < <(read_csv_data)
unset IFS

# Initialize the program
echo "Time Tracker"
echo "Initialized."

# Process user commands
while true; do
  echo "Enter project name (-prj project), 'print', or 'quit': "
  read command

  if [[ "$command" == "quit" ]]; then
    write_csv_data
    echo "Exiting..."
    exit 0
  elif [[ "$command" =~ ^-prj ]]; then
    project=${command#-prj }  # Extract project name from input
    echo "To begin work on $project, enter 'start'"
    read start_input

    if [[ "$start_input" == "start" ]]; then
      start_time=$(date -u +%s)
      project_start_times["$project"]=$start_time
      echo "Started tracking work on $project. start time is $start_time. project start times array is ${project_start_times["$project"]}"
    fi
  elif [[ "$command" == "print" ]]; then
    echo "Enter project name: "
    read -r project
    if [[ -n ${project_start_times["$project"]} ]]; then
      echo "Start time for $project: ${project_start_times["$project"]}"
    else
      echo "No active tracking found for $project."
    fi
  else
    echo "Invalid input."
  fi

  echo "Enter 'stop' to stop work on $project, or 'print' to print time: "
  read stop_input

  if [[ "$stop_input" == "stop" ]]; then
    echo "project start times: ${project_start_times["$project"]}"
    if [[ -n ${project_start_times["$project"]} ]]; then
      stop_time=$(date -u +%s)
      elapsed=$((stop_time - $project_start_times["$project"]))
      project_total_times["$project"]=$((project_total_times["$project"] + elapsed))
      unset $project_start_times["$project"]
      echo "Stopped tracking work on $project."
    else
      echo "No active tracking found for $project."
    fi
  elif [[ "$stop_input" == "print" ]]; then
    echo "Total time spent on $project: ${project_total_times["$project"]} seconds."
  else
    echo "Invalid input."
  fi
done