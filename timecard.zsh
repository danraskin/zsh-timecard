#!/usr/bin/env zsh

# Initialize variables
typeset -A start_times
typeset -A total_times
typeset -A task_times  # Add task_times associative array

CSV_FILE="timetracker.csv"

# Function to read data from CSV file
function read_csv_data {
  if [[ -f "$CSV_FILE" ]]; then
    csvcut -c project,task,start_time,stop_time "$CSV_FILE"
    echo "$CSV_FILE exists"
 
  fi
}

# project='projtest'
# task='tasktest'

# read_csv_data
# echo ${(t)task_times} # prints type
# task_times["$task"]='learn bash'
# task_times["$project"]='write timecard script'
# task_times["$project:$task"]='not sure what goes here'
# echo $task_times["$project"]
# echo $task_times["$project:$task"]


# # Function to write data to the CSV file
# function write_csv_data {
#   echo "project,task,start_time,stop_time" > "$CSV_FILE"
#   for proj_task in ${(k)task_times}; do
#     project=${(s:,:)proj_task}
#     task=${(s,:,)proj_task}
#     echo "$project,$task,${start_times[$task]},${total_times[$task]}" >> "$CSV_FILE"
#   done
# }

# Load existing data from CSV file, if it exists
IFS=,
while read -r project task start_time stop_time; do
  task_times["$project:$task"]=$start_time  # Store the key in "project:task" format
  start_times["$task"]=$start_time
  total_times["$task"]=$stop_time

done < <(read_csv_data) #process substitution syntax. runs function in subshell and redirects output to while loop. how? idk!
unset IFS

# # Parse command-line arguments
# project=""
# task=""

# # this manually parses command-line arguments

# #iterates over cl arguments if >0.
# while [[ $# -gt 0 ]]; do
#   case "$1" in
#     -p|--project)
#       project="$2"
#       shift
#       shift
#       ;;
#     -t|--task)
#       task="$2"
#       shift
#       shift
#       ;;
#     *)
#       break
#       ;;
#   esac
# done

# # Check if project and task are provided
# if [[ -z $project ]]; then
#   echo "Please specify a project using the -p or --project flag."
#   exit 1
# fi

# if [[ -z $task ]]; then
#   echo "Please specify a task using the -t or --task flag."
#   exit 1
# fi

# # Process commands
# while [[ $# -gt 0 ]]; do
#   case "$1" in
#     start)
#       start_times[$task]=$(date +%s)
#       echo "Started tracking task '$task' for project '$project'."
#       echo "start time is $start_times[$task]"
#       echo "start_times is $start_times"
#       ;;
#     stop)
#       if [[ -z ${start_times[$task]} ]]; then
#         echo "No active tracking found for task '$task' in project 
# '$project'."
#       else
#         start_time=${start_times[$task]}
#         end_time=$(date +%s)
#         elapsed=$((end_time - start_time))
#         total_times[$task]=$((total_times[$task] + elapsed))
#         unset start_times[$task]
#         echo "Stopped tracking task '$task' for project '$project'."
#         echo "Total time spent on task '$task': $((total_times[$task])) 
# seconds."
#       fi
#       ;;
#     print)
#       if [[ -z ${total_times[$task]} ]]; then
#         echo "No time tracked for task '$task' in project '$project'."
#       else
#         echo "Total time spent on task '$task' for project '$project': 
# $((total_times[$task])) seconds."
#       fi
#       ;;
#     *)
#       echo "Invalid command: $1"
#       exit 1
#       ;;
#   esac
#   shift
# done
