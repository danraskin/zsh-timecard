#!/usr/bin/env zsh

while true; do
    # Display a custom prompt on the same line as user input
    echo -n " --> "
    
    # Read user input
    read input
    
    # Check if the input is 'q' to exit the script
    if [[ "$input" == "q" ]]; then
        echo "Exiting..."
        exit 0
    elif [[ -n $input ]]; then
        # Echo user input on a new line
        echo "$input"
    else
 
    fi
done