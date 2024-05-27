#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <max_point> <correct_output_file> <submissions_folder>"
    exit 1
fi


max_point=$1
correct_output_file=$2
submissions_folder=$3

echo "Checking the arguments..."

if [[ ! "$1" =~ ^[0-9]+$ || "$1" -lt 1 ]]; then
    echo "Max grade should be a positive integer"
    exit 1
fi

if [ ! -f $correct_output_file ]; then
    echo "Correct output file does not exist!"
    exit 1
fi

if [ ! -d $submissions_folder ]; then  
    echo "Submissions folder does not exist!"
    exit 1
else 
    number_of_submissions=$(ls -A "$3" | wc -l)
    if [ -z "$number_of_submissions" ]; then
        echo "Submission folder is empty!"
        exit 1
    fi
    echo ""$number_of_submissions" number of students submitted homework."
fi


grading_folder="grading"
log_file="$grading_folder/log.txt"
result_file="$grading_folder/result.txt"

if [ ! -d $grading_folder ]; then
    mkdir -m 755 $grading_folder
fi

>$log_file
>$result_file


# Arguments:
# $1 -> full filename
check_file_name() {
    if [[ "$1" =~ ^322_h1_[0-9]{9}\.sh$ ]]; then
        return 0
    else    
        echo "Incorrect file name"
        echo "Incorrect file name format: $1" >> $log_file
        return 1
    fi
}


#Arguments:
# $1 -> exetutuion path 
# $2 -> full filename
# $3 -> student id
execute_shell_script_assignment() {
    timeout 1m "$1" > grading/out.txt
    
    if [ $? -eq 124 ]; then
        echo "timeout has occured"
        echo "Student ID: $3 - too long execution." >> "$log_file"
        echo "Student ID: $3 - 0" >> "$result_file"
        
        if [ -f "grading/out.txt" ]; then
            trimmed_filename=$(basename $2 .sh)    
            mv grading/out.txt "grading/"$trimmed_filename"_out.txt"
        fi

        return 1
    fi

    return 0
}


#Arguments:
# $1 full filename
# $2 student id
evaluate_grade() {
    different_lines=0

    num_lines_correct_output=$(wc -l < $correct_output_file)

    for (( i=1; i<=num_lines_correct_output; i++ )); do
        correct_line=$(sed -n "${i}p" "$correct_output_file")
        student_line=$(sed -n "${i}p" "grading/out.txt")

        if [ "$correct_line" != "$student_line" ]; then
            different_lines=$((different_lines + 1))
        fi
    done
    
    echo "Student ID: "$2" - $((max_point - different_lines))" >> "$result_file"

    trimmed_filename=$(basename $1 .sh)    
    mv grading/out.txt "grading/"$trimmed_filename"_out.txt"
    
}


for submission_file in "$3"/*; do
    filename=$(basename "$submission_file")

    echo "Grading process for "$filename" is started..."
    if ! check_file_name "$filename"; then
        continue
    fi

    echo "checking file permission..."
    if [ ! -x "$submission_file" ]; then
        chmod +x "$submission_file"
        echo "Changed permission of "$filename" to executable"
    fi

    student_id=$(echo "$filename" | cut -d "_" -f 3 | cut -d "." -f 1)
    echo "id is "$student_id""
    if ! execute_shell_script_assignment "$submission_file" "$filename" "$student_id"; then
        continue
    fi

    evaluate_grade "$filename" "$student_id"
done 


echo "********** Grading completed **********"