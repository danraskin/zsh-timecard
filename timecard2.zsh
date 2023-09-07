#!/usr/bin/env zsh

# set variables
project=""

function set_prompt {
  if [[ -n $project ]]; then
    echo -n "\U10348 -> [$project] "
  else
    echo -n "\U10348 -> [ ] "
  fi
}

set_prompt

while getopts ":p:P:q:s:S:" arg; do
  case $arg in
  p)
    project=$OPTARG
    echo "p is $project";;
  P)
    echo "P is print $OPTARG";;
  q)
    echo "exiting..."; exit 0;;
  s)
    echo "${project} starting";;
  S)
    echo "${project} stopping";;
  \?)
    echo "invalid optoin: -$OPTARG"; exit 1;;
  esac
done

shift $((OPTIND -1))

# while true; do

#   read command

# done