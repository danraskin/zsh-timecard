#!/usr/bin/env zsh

# Initialize variables
typeset -A start_times
typeset -A total_times
typeset -A task_times  # Add task_times associative array

CSV_FILE="./timetracker.csv"
echo 'in timecard'
# Function to read data from CSV file
function read_csv_data {
  if [[ -f "$CSV_FILE" ]]; then
      echo "$CSV_FILE exists"
    csvcut -c project,task,start_time,stop_time "$CSV_FILE"

  fi
}

project='projtest'
task='tasktest'

# read_csv_data
# echo ${(t)task_times} # prints type
# task_times["$task"]='learn bash'
# task_times["$project"]='write timecard script'
# task_times["$project:$task"]='not sure what goes here'
# echo $task_times["$project"]
# echo $task_times["$project:$task"]


# # Function to write data to the CSV file
function write_csv_data {
  echo "project,task,start_time,stop_time" > "$CSV_FILE"
  for proj_task in ${(k)task_times}; do
    project=${(s:,:)proj_task}
    task=${(s,:,)proj_task}
    echo "$project,$task,${start_times[$task]},${total_times[$task]}" >> "$CSV_FILE"
  done
}

# Load existing data from CSV file, if it exists
IFS=,
while read -r index project task start_time stop_time; do
  task_times["$index:$project:$task"]=$start_time  # Store the key in "project:task" format
  echo $task_times["$index:$project:$task"]
  start_times["$task"]=$start_time
  total_times["$task"]=$stop_time
done < <(read_csv_data) #process substitution syntax. runs function in subshell and redirects output to while loop. how? idk!
unset IFS

# echo $task_times["code:timecard"]

