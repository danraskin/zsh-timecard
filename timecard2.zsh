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
    if [[ -n $project_current[start_time] && -z $project_current[stop_time] ]]; then
      echo -n "\e[0;36m\U10348 ->\e[0m  -> ["${project_current[prj_name]}"]["${project_current[task]}"] "
    else
      echo -n "\U10348 -> ["${project_current[prj_name]}"]["${project_current[task]}"] "
    fi
  elif [[ (-n $project_current[prj_name]) && (-z $project_current[task]) ]]; then
    if [[ -n $project_current[start_time] && -z $project_current[stop_time] ]]; then
      echo -n "\e[0;36m\U10348 ->\e[0m ["${project_current[prj_name]}"][ ] "
    else
      echo -n "\U10348 -> ["${project_current[prj_name]}"][ ] "
    fi
  else
    echo -n "\U10348 -> [ ][ ] "
  fi
}

# Function to write data to the CSV file
function write_csv_data {
  index=$((highest_index + 1))
  date=$(date -u +%Y-%m-%d)
  echo "$index,$date,$project_current[prj_name],$project_current[task],$project_current[start_time],$project_current[stop_time]" >> "$CSV_FILE"
  (( highest_index++ ))
  project_current[start_time]=""
  project_current[stop_time]=""
}

function cmd_print {
  declare -A task_times  # Associative array to store task times
  total_project_time=0

    while IFS=, read -r index date project task start_time stop_time; do
      if [[ ($command == "print") ]]; then
        if [[ $index =~ ^[0-9]+$ ]]; then
          start_timestamp=$(date -r "$start_time" +%s)
          stop_timestamp=$(date -r "$stop_time" +%s)
          duration=$((stop_timestamp - start_timestamp))
          total_project_time=$((total_project_time + duration))

          # Update task times
          if [[ -n $project ]]; then
            (( task_times[$project] += duration ))
          fi
        fi
      elif [[ -n ${command#print } ]]; then
        designated_project=${command#print }
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
      fi
    done < <(read_csv_data)

    # Print table header
    printf "%-10s | %-10s | %-10s\n" "Project" "Task" "Time"
    printf "-----------|------------|----------\n"

    # Print task-wise times in a table
    for task in ${(k)task_times}; do
      if [[ -n $designated_project ]]; then
        printf "%-10s | %-10s | %02dh:%02dm\n" "$designated_project" "$task" $((task_times[$task] / 3600)) $((task_times[$task] % 3600 / 60)) 
      else
        printf "%-10s | %-10s | %02dh:%02dm\n" "$task" "" $((task_times[$task] / 3600)) $((task_times[$task] % 3600 / 60)) 
      fi
    done

    # Print total project time
    printf "-----------|------------|----------\n"
    printf "%-23s | %02dh:%02dm\n" "Total Project Time" $((total_project_time / 3600)) $((total_project_time % 3600 / 60)) 
    printf "-----------------------------------\n"
    
  # fi
}

function cmd_quit {
  echo "Exiting..."
  exit 0
}

function cmd_set_proj {
  if [[ (-n $project_current[start_time]) && (-z $project_current[stop_time]) ]]; then
    echo "stop current project? Y/n"
    while true; do
      read response    
      case $response in
        [yY])
          cmd_stop
          project_current[prj_name]=${command#-p }  # Extract project name from input
          echo "To begin work on $project_current[prj_name], enter 'start'"
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
    echo "To begin work on $project_current[prj_name], enter 'start'"
  fi
}

function cmd_start {
  if [[ (-n $project_current[prj_name]) && (-z $project_current[start_time]) ]]; then
    start_time=$(date -u +%s)
    project_current[start_time]=$start_time
  elif [[ -n $project_current[start_time] ]]; then
    echo "time is already being tracked"
  elif [[ -z $project_current[prj_name] ]]; then
    echo "no project has been chosen"
  fi
}

function cmd_stop {
  if [[ (-n $project_current[start_time]) ]]; then
      stop_time=$(date -u +%s)
      project_current[stop_time]=$stop_time
      echo "Stopped tracking $project_current[prj_name]"
      write_csv_data
    else
      echo "No active tracking found for $project_current[prj_name]."
  fi
}

load_csv_data

# Process user commands
while true; do

  set_prompt
  read command

  case $command in
    "quit")
      cmd_quit
    ;;
    "-p "*)
      clear
      cmd_set_proj
    ;;
    "start")
      clear
      cmd_start
    ;;
    "stop")
      clear
      cmd_stop
    ;;
    "print"*)
      clear
      cmd_print
    ;;
    *)
      echo "Invalid input."
    ;;
  esac
  
done