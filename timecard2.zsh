#!/usr/bin/env zsh

declare -A project_start_times
declare -A project_stop_times
CSV_FILE="timetracker.csv"
highest_index=0
project_current=""
task=""

# Function to read data from CSV file
function read_csv_data {
  if [[ -f "$CSV_FILE" ]]; then
    csvcut -c index,project,start_time,stop_time "$CSV_FILE"
  fi
}

function load_csv_data {
  # Load existing data from CSV file, if it exists
  IFS=,
  while read -r index prj start_time stop_time; do
    # echo "in loop $prj"
    project_start_times["$index:$prj"]=$start_time
    project_stop_times["$index:$prj"]=$stop_time
    if  [[ (( index > highest_index )) ]] ; then
      highest_index=$index
    fi
  done < <(read_csv_data)
  unset IFS
}

# U+10348
# function to display prompt
## -n is a test operator. true if length of string is non-zero. -z true if length is zero
function set_prompt {
  if [[ (-n $project_current) && (-n $task) ]]; then
    echo -n "\U10348 -> [$project_current][$task] "
  elif [[ (-n $project_current) && (-z $task) ]]; then
    echo -n "\U10348 -> [$project_current][ ] "
  else
    echo -n "\U10348 -> [ ][ ] "
  fi
}

# Function to write data to the CSV file
function write_csv_data {
  index=$((highest_index + 1))
  echo "$index,$project_current,$project_start_times["$project_current"],$project_stop_times["$project_current"]" >> "$CSV_FILE"
  (( index++ ))
}

function cmd_print {
  echo "Total time spent on $project_current:  seconds."
  set_prompt
}

function cmd_quit {
  echo "Exiting..."
  exit 0
}

function cmd_set_proj {
  project_current=${command#-p }  # Extract project name from input
  echo "To begin work on $project_current, enter 'start'"
}

function cmd_start {
  if [[ (-n $project_current) && (-z $project_start_times["$project_current"]) ]]; then
    start_time=$(date -u +%s)
    project_start_times["$project_current"]=$start_time
    echo "project start time is: $project_start_times["$project_current"]"
  elif [[ -n $project_start_times["$project_current"] ]]; then
    echo "time is already being tracked"
  elif [[ -z $project_current ]]; then
    echo "no project has been chosen"
  fi
}

function cmd_stop {
  echo ${(@k)project_start_times}
  if [[ (-n $project_start_times["$project_current"])]]; then
      stop_time=$(date -u +%s)
      project_stop_times["$project_current"]=$stop_time
      echo "Stopped tracking work on $project_current"
      write_csv_data
    else
      echo "No active tracking found for $project_current."
  fi
}



# Process user commands
while true; do
  # echo "project_start_times are: ${(@k)project_start_times}"
  load_csv_data
  # echo $project_start_times
  echo "Enter project name (-p project) or 'quit': "
  set_prompt
  read command

  case $command in
    "quit")
      cmd_quit
    ;;
    "-p "*)
      cmd_set_proj
    ;;
    "start")
      cmd_start
    ;;
    "stop")
      cmd_stop
    ;;
    "print")
      cmd_print
    ;;
    *)
      echo "Invalid input."
    ;;
  esac
  

  # echo "Enter 'stop' to stop work on $project, or 'print' to print time: "
  # set_prompt
  # read stop_input

  # if [[ "$stop_input" == "stop" ]]; then
  #   if [[ -n ${project_start_times["$project"]} ]]; then
  #     stop_time=$(date -u +%s)
  #     echo "Stopped tracking work on $project."
  #     write_csv_data
  #     echo "written to timetracker.csv"
  #   else
  #     echo "No active tracking found for $project."
  #   fi
  # elif [[ "$stop_input" == "print" ]]; then
  #   echo "Total time spent on $project: ${project_total_times["$project"]} seconds."
  #   set_prompt
  # else
  #   echo "Invalid input."
  #   set_prompt
  # fi
done



# while getopts ":p:P:q:s:S:" arg; do
#   case $arg in
#   p)
#     project=$OPTARG
#     echo "p is $project";;
#   P)
#     echo "P is print $OPTARG";;
#   q)
#     echo "exiting..."; exit 0;;
#   s)
#     echo "${project} starting";;
#   S)
#     echo "${project} stopping";;
#   \?)
#     echo "invalid optoin: -$OPTARG"; exit 1;;
#   esac
# done

# shift $((OPTIND -1))
