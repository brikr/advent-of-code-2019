#!/bin/bash

compute() {
  IFS=',' read -r -a input <<< $(cat input.txt)
  input[1]=$1
  input[2]=$2

  for idx in `seq 0 4 ${#input[@]}`; do
    case ${input[idx]} in
      1)
        # Add
        idx_a=${input[idx+1]}
        a=${input[idx_a]}

        idx_b=${input[idx+2]}
        b=${input[idx_b]}

        idx_c=${input[idx+3]}
        let c=$a+$b
        input[$idx_c]=$c
        ;;
      2)
        # Multiply
        idx_a=${input[idx+1]}
        a=${input[idx_a]}

        idx_b=${input[idx+2]}
        b=${input[idx_b]}

        idx_c=${input[idx+3]}
        let c=$a\*$b
        input[$idx_c]=$c
        ;;
      99)
        # Halt
        echo ${input[0]}
        return
        ;;
      *)
        echo ERROR HELP
        exit 1
        ;;
    esac
  done
}

# Part 1
p1=$(compute 12 2)
echo "Part 1: $p1"

# Part 2
for i in `seq 0 99`; do
  echo "Trying noun $i"
  for j in `seq 0 99`; do
    val=$(compute $i $j)
    if [ $val == "19690720" ]; then
      let ans=$i*100+$j
      echo "Part 2: $ans"
      exit 0
    fi
  done
done
echo ERROR HELP
exit 1