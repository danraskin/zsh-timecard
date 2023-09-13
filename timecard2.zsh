#!/usr/bin/env zsh

declare -A project_current

project_current=(prj_name "" task "" start_time "" stop_time "" break_times "")


# declare -A project_stop_times
CSV_FILE="timetracker.csv"
highest_index=0
# project_current=""
# task=""

# Function to read data from CSV file
function read_csv_data {
  if [[ -f "$CSV_FILE" ]]; then
    csvcut -c index,date,project,task,start_time,stop_time "$CSV_FILE"
  else
    echo "index,date,project,task,start_time,stop_time" >> "$CSV_FILE"
  fi
}

function load_csv_data {
  # Load existing data from CSV file, if it exists
  echo 'loading...'
  IFS=,
  while read -r index prj start_time stop_time; do
    # echo "in loop $prj"
    # project_start_times["$index:$prj"]=$start_time
    # project_stop_times["$index:$prj"]=$stop_time
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
  if [[ (-n $project_current[prj_name]) && (-n $project_current[task]) ]]; then
    echo -n "\U10348 -> ["${project_current[prj_name]}"]["${project_current[task]}"] "
  elif [[ (-n $project_current[prj_name]) && (-z $project_current[task]) ]]; then
    echo -n "\U10348 -> ["${project_current[prj_name]}"][ ] "
  else
    echo -n "\U10348 -> [ ][ ] "
  fi
}

# Function to write data to the CSV file
function write_csv_data {
  index=$((highest_index + 1))
  date=$(date -u +%Y-%m-%d)
  echo "$index,$date,$project_current[prj_name],$project_current[task],$project_current[start_time],$project_current[stop_time]" >> "$CSV_FILE"
  (( index++ ))
  project_current[start_time]=""
  project_current[stop_time]=""
  echo "writing. $project_current"
}

function cmd_print {

  if [[ ($command == "print") && (-z $project_current[prj_name]) ]]; then
    echo "chose project to print"
    return
  elif [[ ($command == "print") && (-n $project_current[prj_name]) ]]; then
    designated_project=$project_current[prj_name]
  elif [[ -n ${command#print } ]]; then
    designated_project=${command#print }
  fi

  declare -A task_times  # Associative array to store task times
  total_project_time=0

  if [[ (-n $project_current[start_time]) && (-z $project_current[stop_time]) ]]; then
    echo "Cannot print total time while a project is active. Please stop the project first."
  else
    while IFS=, read -r index date project task start_time stop_time; do
      if [[ $project == $designated_project && -n $start_time && -n $stop_time ]]; then
        start_timestamp=$(date -r "$start_time" +%s)
        stop_timestamp=$(date -r "$stop_time" +%s)
        duration=$((stop_timestamp - start_timestamp))
        total_project_time=$((total_project_time + duration))

        # Update task times
        if [[ -n $task ]]; then
          (( task_times[$task] += duration ))
        else
          (( task_times[$designated_project] += duration ))
        fi
      fi
    done < <(read_csv_data)

    # Print table header
    printf "%-10s | %-10s | %-10s\n" "Project" "Task" "Time"
    printf "-----------|------------|----------\n"

    # Print task-wise times in a table
    for task in ${(k)task_times}; do
      printf "%-10s | %-10s | %-10d\n" "$designated_project" "$task" "$task_times[$task]"
    done

    # Print total project time
    printf "-----------|------------|----------\n"
    printf "%-23s | %-10d\n" "Total Project Time" "$total_project_time"
    printf "-----------------------------------\n"
    
  fi
}

function cmd_quit {
  echo "Exiting..."
  exit 0
}

function cmd_set_proj {
  # echo $project_current[@]
  if [[ (-n $project_current[start_time]) && (-z $project_current[stop_time]) ]]; then
    echo "stop current project? Y/n"
    while true; do
      read response    
      case $response in
        [yY])
          cmd_stop
          project_current[prj_name]=${command#-p }  # Extract project name from input
          echo "To begin work on $project_current, enter 'start'"
          break
        ;;
        [nN])
          break
        ;;
        *)
          echo "invalid input. please enter 'y' or 'n'"
        ;;
      esac
    done
  else 
    project_current[prj_name]=${command#-p }  # Extract project name from input
    echo "To begin work on $project_current, enter 'start'"
  fi
}

function cmd_start {
  if [[ (-n $project_current[prj_name]) && (-z $project_current[start_time]) ]]; then
    start_time=$(date -u +%s)
    project_current[start_time]=$start_time
    echo "project start time is: $project_current[start_time]"
  elif [[ -n $project_current[start_time] ]]; then
    echo "time is already being tracked"
  elif [[ -z $project_current[prj_name] ]]; then
    echo "no project has been chosen"
  fi
}

function cmd_stop {
  # echo ${(@k)project_start_times}
  if [[ (-n $project_current[start_time]) ]]; then
      stop_time=$(date -u +%s)
      project_current[stop_time]=$stop_time
      echo "Stopped tracking work on $project_current[prj_name]"
      write_csv_data
    else
      echo "No active tracking found for $project_current[prj_name]."
  fi
}

load_csv_data

# Process user commands
while true; do
  # echo "project_start_times are: ${(@k)project_start_times}"
  # load_csv_data
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
    "print"*)
      cmd_print
    ;;
    *)
      echo "Invalid input."
    ;;
  esac
  
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
