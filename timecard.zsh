#!/usr/bin/env zsh

declare -A project_start_times
declare -A project_total_times
CSV_FILE="timetracker.csv"
highest_index=0

# generate unicode
# function generate_unicode_char {
#   echo -e "\U$((0x1F600 + RANDOM % 50))"
# }

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
  if  [[ index =~ ^[0-9]+$ && (( index > highest_index )) ]] ; then
    highest_index=$index
    echo $index $highest_index
  fi
done < <(read_csv_data)
unset IFS


# Initialize the program
echo "Time Tracker"

# Hook the function to the 'precmd' hook, which runs before each prompt display
# autoload -U add-zsh-hook
# add-zsh-hook precmd set_prompt


# Process user commands
while true; do
  echo "Enter project name (-p project) or 'quit': "
  set_prompt
  read command

  if [[ "$command" == "quit" ]]; then
    echo "Exiting..."
    exit 0
  elif [[ "$command" =~ ^-p ]]; then
    project=${command#-p }  # Extract project name from input
    echo "To begin work on $project, enter 'start'"
    set_prompt
    read start_input

    if [[ "$start_input" == "start" ]]; then
      start_time=$(date -u +%s)
      project_start_times["$project"]=$start_time
      # echo "Started tracking work on $project. start time is $start_time. project start times array is ${project_start_times["$project"]}"
    fi
  elif [[ "$command" == "print" ]]; then
    print_project_times
  else
    echo "Invalid input."
    set_prompt
  fi
  

  echo "Enter 'stop' to stop work on $project, or 'print' to print time: "
  set_prompt
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
    set_prompt
  else
    echo "Invalid input."
    set_prompt
  fi
done