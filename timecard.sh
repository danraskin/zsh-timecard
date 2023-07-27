#!/usr/bin/env zsh

# Initialize variables
typeset -A start_times
typeset -A total_times

# Parse command-line arguments
project=""
task=""

# this manually parses command-line arguments

#iterates over cl arguments if >0.
while [[ $# -gt 0 ]]; do
  case "$1" in
    -p|--project)
      project="$2"
      shift
      shift
      ;;
    -t|--task)
      task="$2"
      shift
      shift
      ;;
    *)
      break
      ;;
  esac
done

# Check if project and task are provided
if [[ -z $project ]]; then
  echo "Please specify a project using the -p or --project flag."
  exit 1
fi

if [[ -z $task ]]; then
  echo "Please specify a task using the -t or --task flag."
  exit 1
fi

# Process commands
while [[ $# -gt 0 ]]; do
  case "$1" in
    start)
      start_times[$task]=$(date +%s)
      echo "Started tracking task '$task' for project '$project'."
      ;;
    stop)
      if [[ -z ${start_times[$task]} ]]; then
        echo "No active tracking found for task '$task' in project 
'$project'."
      else
        start_time=${start_times[$task]}
        end_time=$(date +%s)
        elapsed=$((end_time - start_time))
        total_times[$task]=$((total_times[$task] + elapsed))
        unset start_times[$task]
        echo "Stopped tracking task '$task' for project '$project'."
        echo "Total time spent on task '$task': $((total_times[$task])) 
seconds."
      fi
      ;;
    print)
      if [[ -z ${total_times[$task]} ]]; then
        echo "No time tracked for task '$task' in project '$project'."
      else
        echo "Total time spent on task '$task' for project '$project': 
$((total_times[$task])) seconds."
      fi
      ;;
    *)
      echo "Invalid command: $1"
      exit 1
      ;;
  esac
  shift
done
