#!/bin/bash
 
# Define the input and output file names
input_csv="input.csv"
output_csv="output.csv"
 
# Write the header of the output CSV file
echo "URL,overview,campus,courses,scholarships,admission,placement,results" > "$output_csv"
 
# Initialize an associative array for storing the data
declare -A data
 
# Read the input CSV line by line, skipping the header
tail -n +2 "$input_csv" | while IFS=, read -r url description; do
    # Extract the domain and path for categorization
    domain=$(echo "$url" | awk -F/ '{print $3}')
    path=$(echo "$url" | awk -F/ '{print $4}')

    # Initialize the categories as empty
    overview=""
    campus=""
    courses=""
    scholarships=""
    admission=""
    placement=""
    results=""

    # Categorize the description based on the URL path
    case "$path" in
        "ai")
            case "$url" in
                *"overview"*) overview="$description" ;;
                *"campus"*) campus="$description" ;;
                *"courses"*) courses="$description" ;;
                # Add more cases as needed
            esac
            ;;
        "php")
            case "$url" in
                *"campus"*) campus="$description" ;;
                *"courses"*) courses="$description" ;;
                *"scholarships"*) scholarships="$description" ;;
                *"admission"*) admission="$description" ;;
                # Add more cases as needed
            esac
            ;;
    esac

    # Construct the line for this URL
    line="$domain,$overview,$campus,$courses,$scholarships,$admission,$placement,$results"

    # Check if this domain is already in the data array
    if [[ -z "${data[$domain]}" ]]; then
        # If not, add this line to the array
        data["$domain"]="$line"
    else
        # If it is, update the existing line
        existing="${data[$domain]}"
        # This is a simple string replacement example; you might need a more sophisticated merging logic
        updated=$(echo "$existing" | awk -v ov="$overview" -v ca="$campus" -v co="$courses" -v sc="$scholarships" -v ad="$admission" 'BEGIN{FS=OFS=","} {if(ov!="") $2=ov; if(ca!="") $3=ca; if(co!="") $4=co; if(sc!="") $5=sc; if(ad!="") $6=ad; print}')
        data["$domain"]="$updated"
    fi
done
 
# Write the data from the associative array to the output CSV
for key in "${!data[@]}"; do
    echo "${data[$key]}" >> "$output_csv"
done
