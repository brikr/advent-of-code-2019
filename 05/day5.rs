use std::fs;

fn main() {
  let contents = fs::read_to_string("input.txt")
    .expect("Something went wrong reading the file");

  let instructions_iter = contents.split(",").map(|s| s.parse::<i32>().unwrap());
  let mut data = instructions_iter.collect::<Vec<_>>();

  // Part 1
  // let input = 1;
  // Part 2
  let input = 5;

  let mut i = 0;
  while i < data.len() {
    let instruction_full = data[i];
    let instruction = instruction_full % 100;
    // println!("Handling Opcode {} @ {}", instruction, i);
    if instruction == 1 {
      // Add
      let mut arg1 = data[i+1];
      let mut arg2 = data[i+2];
      let arg3 = data[i+3];

      let arg1_mode = (instruction_full / 100) % 10;
      let arg2_mode = (instruction_full / 1000) % 100;

      // println!("  {} ({}), {} ({}), {}", arg1, arg1_mode, arg2, arg2_mode, arg3);

      process_arg(&mut arg1, &mut data, arg1_mode);
      process_arg(&mut arg2, &mut data, arg2_mode);

      // println!("  data[{}] <- {} + {} = {}", arg3, arg1, arg2, arg1 + arg2);
      data[arg3 as usize] = arg1 + arg2;

      i += 4;
    } else if instruction == 2 {
      // Multiply
      let mut arg1 = data[i+1];
      let mut arg2 = data[i+2];
      let arg3 = data[i+3];

      let arg1_mode = (instruction_full / 100) % 10;
      let arg2_mode = (instruction_full / 1000) % 100;

      // println!("  {} ({}), {} ({}), {}", arg1, arg1_mode, arg2, arg2_mode, arg3);

      process_arg(&mut arg1, &mut data, arg1_mode);
      process_arg(&mut arg2, &mut data, arg2_mode);

      // println!("  data[{}] <- {} * {} = {}", arg3, arg1, arg2, arg1 * arg2);
      data[arg3 as usize] = arg1 * arg2;

      i += 4;
    } else if instruction == 3 {
      // Store input
      let arg1 = data[i+1];

      // println!("  data[{}] <- {}", arg1, input);

      data[arg1 as usize] = input;

      i += 2;
    } else if instruction == 4 {
      // Produce output
      let mut arg1 = data[i+1];
      let arg1_mode = (instruction_full / 100) % 10;

      process_arg(&mut arg1, &mut data, arg1_mode);

      println!("  OUTPUT: {}", arg1);

      i += 2;
    } else if instruction == 5 {
      // Jump if true
      let mut arg1 = data[i+1];
      let mut arg2 = data[i+2];

      let arg1_mode = (instruction_full / 100) % 10;
      let arg2_mode = (instruction_full / 1000) % 100;

      // println!("  {} ({}), {} ({})", arg1, arg1_mode, arg2, arg2_mode);

      process_arg(&mut arg1, &mut data, arg1_mode);
      process_arg(&mut arg2, &mut data, arg2_mode);

      // println!("  {}, {}", arg1, arg2);

      if arg1 != 0 {
        i = arg2 as usize;
        // println!("  Jumping to {}", i);
      } else {
        i += 3;
      }
    } else if instruction == 6 {
      // Jump if false
      let mut arg1 = data[i+1];
      let mut arg2 = data[i+2];

      let arg1_mode = (instruction_full / 100) % 10;
      let arg2_mode = (instruction_full / 1000) % 100;

      // println!("  {} ({}), {} ({})", arg1, arg1_mode, arg2, arg2_mode);

      process_arg(&mut arg1, &mut data, arg1_mode);
      process_arg(&mut arg2, &mut data, arg2_mode);

      // println!("  {}, {}", arg1, arg2);

      if arg1 == 0 {
        i = arg2 as usize;
        // println!("  Jumping to {}", i);
      } else {
        i += 3;
      }
    } else if instruction == 7 {
      // Less than
      let mut arg1 = data[i+1];
      let mut arg2 = data[i+2];
      let arg3 = data[i+3];

      let arg1_mode = (instruction_full / 100) % 10;
      let arg2_mode = (instruction_full / 1000) % 100;

      // println!("  {} ({}), {} ({}), {}", arg1, arg1_mode, arg2, arg2_mode, arg3);

      process_arg(&mut arg1, &mut data, arg1_mode);
      process_arg(&mut arg2, &mut data, arg2_mode);

      // println!("  {}, {}, {}", arg1, arg2, arg3);

      if arg1 < arg2 {
        data[arg3 as usize] = 1;
        // println!("  data[{}] <- 1", arg3);
      } else {
        data[arg3 as usize] = 0;
        // println!("  data[{}] <- 0", arg3);
      }

      i += 4;
    } else if instruction == 8 {
      // Equals
      let mut arg1 = data[i+1];
      let mut arg2 = data[i+2];
      let arg3 = data[i+3];

      let arg1_mode = (instruction_full / 100) % 10;
      let arg2_mode = (instruction_full / 1000) % 100;

      // println!("  {} ({}), {} ({}), {}", arg1, arg1_mode, arg2, arg2_mode, arg3);

      process_arg(&mut arg1, &mut data, arg1_mode);
      process_arg(&mut arg2, &mut data, arg2_mode);

      // println!("  {}, {}, {}", arg1, arg2, arg3);

      if arg1 == arg2 {
        data[arg3 as usize] = 1;
        // println!("  data[{}] <- 1", arg3);
      } else {
        data[arg3 as usize] = 0;
        // println!("  data[{}] <- 0", arg3);
      }

      i += 4;
    } else if instruction == 99 {
      // Halt
      return
    } else {
      println!("halp");
      return
    }
  }
}

fn process_arg(arg: &mut i32, data: &mut [i32], mode: i32) {
  if mode == 0 {
    // Position mode
    *arg = data[*arg as usize];
  }
  // else immediate mode; arg is what we want already.
}
