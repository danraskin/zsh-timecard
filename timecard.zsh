#!/usr/bin/env zsh


declare -A project_start_times
declare -A project_total_times
CSV_FILE="timetracker.csv"
highest_index=0

# Function to read data from CSV file
function read_csv_data {
  if [[ -f "$CSV_FILE" ]]; then
    csvcut -c index,project,start_time,stop_time "$CSV_FILE"
  fi
}

# Function to write data to the CSV file
function write_csv_data {
  index=$((highest_index + 1))
  # echo "index,project,start_time,stop_time" > "$CSV_FILE"
  echo "$index,$project,$start_time,$stop_time" >> "$CSV_FILE"
  (( index++ ))
  # for project in ${(k)project_start_times}; do
  #   for start_time in ${(P)project_start_times[$project]}; do
  #     stop_time=${project_total_times["$index:$project:$start_time"]:-}
  #     echo "$index,$project,$start_time,$stop_time" >> "$CSV_FILE"
  #     (( index++ ))
  #   done
  # done
}

# Load existing data from CSV file, if it exists
IFS=,
while read -r index project start_time stop_time; do
  project_start_times["$index:$project"]=$start_time
  project_total_times["$index:$project"]=$stop_time
  if (( index > highest_index )); then
    highest_index=$index
  fi
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
    print_project_times
  else
    echo "Invalid input."
  fi
  

  echo "Enter 'stop' to stop work on $project, or 'print' to print time: "
  read stop_input

  if [[ "$stop_input" == "stop" ]]; then
    if [[ -n ${project_start_times["$project"]} ]]; then
      stop_time=$(date -u +%s)
      echo "Stopped tracking work on $project."
      write_csv_data
      echo "written to timetracker.csv"
    else
      echo "No active tracking found for $project."
    fi
  elif [[ "$stop_input" == "print" ]]; then
    echo "Total time spent on $project: ${project_total_times["$project"]} seconds."
  else
    echo "Invalid input."
  fi
done