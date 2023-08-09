#!/usr/bin/env zsh

typeset -A project_start_times
typeset -A project_total_times

# Process user commands
while true; do
  echo "Enter project name (-prj project) or 'quit': "
  read command

  if [[ "$command" == "quit" ]]; then
    echo "Exiting..."
    exit 0
  elif [[ "$command" =~ ^-prj ]]; then
    project=${command#-prj }  # Extract project name from input
    start_time=$(date -u +%s)
    project_start_times["$project"]=$start_time
    echo "Started tracking work on $project. Start time: $start_time"
  elif [[ "$command" == "print" ]]; then
    echo "Enter project name: "
    read -r project_input
    if [[ -n ${project_start_times["$project_input"]} ]]; then
      echo "Start time for $project_input: ${project_start_times["$project_input"]}"
    else
      echo "No active tracking found for $project_input."
    fi
  else
    echo "Invalid input."
  fi
done