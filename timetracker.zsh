#!/usr/bin/env zsh

# FUNCTIONS

# Function to write data to the CSV file
write_csv_data () {
  index=$((highest_index + 1))
  date=$(date -u +%Y-%m-%d)
  
  echo "$index,$date,$project_current[prj_name],$project_current[task],$project_current[start_time],$project_current[stop_time]" >> "$CSV_FILE"
  (( highest_index++ ))
  project_current[start_time]=""
  project_current[stop_time]=""
}

# initial load of CSV file
load_csv () {
  # check if timetracker.csv exists
  if [[ ! -f $CSV_FILE ]]; then
    echo "index,date,project,task,start_time,stop_time" > "$CSV_FILE"
  fi

  # sets index
  tail -n +2 "$CSV_FILE" | while IFS=, read -r index date; do
    if  [[ (( index > highest_index )) ]] ; then
      highest_index=$index
    fi
  done
}

# sets display prompt
set_prompt () {
  if [[ (-n $project_current[prj_name]) && (-n $project_current[task]) ]]; then
    if [[ -n $project_current[start_time] && -z $project_current[stop_time] ]]; then
      echo -n "\e[0;36m\U10348 ->\e[0m ["${project_current[prj_name]}"]["${project_current[task]}"] "
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

cmd_help () {
  echo "Timetracker \U10348 -> A simple time tracking script"
  echo "Usage: timetracker [OPTIONS]"
  echo "Options:"
  echo "  -p PROJECT  Start tracking a project"
  echo "  -t TASK     Start tracking a task (must be used with -p)"
  echo "  -pt PROJECT Start tracking a project and task"
  echo "  start       Start tracking time for the current project/task"
  echo "  stop        Stop tracking time for the current project/task"
  echo "  print       Print work history"
  echo "  help, -h    Show this help message"

}

# prints time log
cmd_print () {

  local args=(${(s: :)1})
  declare -A local task_times  # Associative array to store task times
  local total_project_time=0

  tail -n +2 "$CSV_FILE" | while IFS=, read -r index date project task start_time stop_time; do
    if [[ ($#args == 1) ]]; then
      local start_timestamp=$(date -r "$start_time" +%s)
      local stop_timestamp=$(date -r "$stop_time" +%s)
      local duration=$((stop_timestamp - start_timestamp))
      local total_project_time=$((total_project_time + duration))

      # Update task times
      if [[ -n $project ]]; then
        (( task_times[$project] += duration ))
      fi
    elif [[ -n $args[2] ]]; then
      local designated_project=$args[2]
      if [[ $project == $designated_project ]]; then
        local start_timestamp=$(date -r "$start_time" +%s)
        local stop_timestamp=$(date -r "$stop_time" +%s)
        local duration=$((stop_timestamp - start_timestamp))
        local total_project_time=$((total_project_time + duration))

        # Update task times
        if [[ -n $task ]]; then
          (( task_times[$task] += duration ))
        else
          (( task_times[$designated_project] += duration ))
        fi
      fi
    fi
  done

  # Print table header
  printf "%-20s | %-20s | %-10s\n" "Project" "Task" "Time"
  printf "---------------------|----------------------|----------\n"

  # Print task-wise times in a table
  for task in ${(k)task_times}; do
    if [[ -n $designated_project ]]; then
      printf "%-20s | %-20s | %02dh:%02dm\n" "$designated_project" "$task" $((task_times[$task] / 3600)) $((task_times[$task] % 3600 / 60)) 
    else
      printf "%-20s | %-20s | %02dh:%02dm\n" "$task" "" $((task_times[$task] / 3600)) $((task_times[$task] % 3600 / 60)) 
    fi
  done

  # Print total project time
  printf "---------------------|----------------------|----------\n"
  printf "%-43s | %02dh:%02dm\n" "Total Project Time" $((total_project_time / 3600)) $((total_project_time % 3600 / 60)) 
  printf "--------------------------------------------------------\n"
}

# user input sets project and task
cmd_set_proj () {
  local args=(${(s: :)1})

  if [[ (-n $project_current[start_time]) && (-z $project_current[stop_time]) ]]; then
    cmd_stop
  fi
  case $args[1] in
    -p)
      project_current[task]=""
      project_current[prj_name]=$args[2]
      echo "To begin tracking $project_current[prj_name], enter 'start'"
    ;;
    -t)
      if [[ -n $project_current[prj_name] ]]; then
        project_current[task]=$args[2]
        echo "To begin tracking $project_current[prj_name], enter 'start'"
      else
        echo "Set a project"
        return
      fi
    ;;
    -pt)
      project_current[prj_name]=$args[2]
      project_current[task]=$args[3]
      echo "To begin tracking $project_current[prj_name], enter 'start'"
    ;;
    *)
      echo "Invalid tag"
    ;;
  esac
}

cmd_start () {
  if [[ (-n $project_current[prj_name]) && (-z $project_current[start_time]) ]]; then
    start_time=$(date -u +%s)
    project_current[start_time]=$start_time
    echo "To stop tracking project_current[prj_name], enter 'stop'"
  elif [[ -n $project_current[start_time] ]]; then
    echo "$project_current[prj_name] is already being tracked"
  elif [[ -z $project_current[prj_name] ]]; then
    echo "No project has been chosen"
  fi
}

cmd_stop () {
  if [[ (-n $project_current[start_time]) ]]; then
    stop_time=$(date -u +%s)
    project_current[stop_time]=$stop_time
    echo "To begin tracking $project_current[prj_name], enter 'start'"
    write_csv_data
  else
    echo "$project_current[prj_name] is not being tracked"
  fi
}

cmd_quit () {
  echo "Exiting..."
  exit 0
}

## TIMETRACKER SCRIPT RUN

# declarations

# gets absolute file path
script_path="$(readlink -f "$0")"
script_dir="$(dirname "$script_path")"
# Construct the path to the CSV file
CSV_FILE="${script_dir}/timetracker.csv"

declare -A project_current
project_current=(prj_name "" task "" start_time "" stop_time "" break_times "")
highest_index=0

# initial functions
load_csv
# clear
echo "<- \U10348 TIMETRACKER \U10348 ->"
echo "To set a project, use -p PROJECT. For help, type -H"

# Process user commands
while true; do

  set_prompt
  read command

  case $command in
    "quit")
      cmd_quit
    ;;
    "-p "* || "-t "* || "-pt "* )
      clear
      cmd_set_proj "$command"
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
      cmd_print "$command"
    ;;
    "help" || "-h")
      clear
      cmd_help
    ;;
    *)
      echo "invalid input"
    ;;
  esac
  
done