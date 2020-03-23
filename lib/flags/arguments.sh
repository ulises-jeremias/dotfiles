# util function
has_param() {
    local term="$1"
    shift
    for arg; do
        if [[ $arg == "$term" ]]; then
            return 0
        fi
    done
    return 1
}

# $@ here represents all arguments passed in
for i in "$@"
do
  arguments[$index]=$i;
  prev_index="$(expr $index - 1)";

  # this if block does something akin to "where $i contains ="
  # "%=*" here strips out everything from the = to the end of the argument leaving only the label
  if [[ $i == *"="* ]]
    then argument_label=${i%=*}
    else argument_label=${arguments[$prev_index]}
  fi

  if [[ -n $argument_label ]]; then
    # this if block only evaluates to true if the argument label exists in the variables array
    if [[ -n ${variables[$argument_label]} ]]; then
      # dynamically creating variables names using declare
      # "#$argument_label=" here strips out the label leaving only the value
      if [[ $i == *"="* ]]
        then declare ${variables[$argument_label]}=${i#$argument_label=} 
        else declare ${variables[$argument_label]}=${arguments[$index]}
      fi
    fi
  fi

  index=index+1;
done;
