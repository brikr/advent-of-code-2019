#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct amp_state {
  int i_ptr;
  int *memory;
  size_t program_size;
  char halted;
  int last_output;
};
typedef struct amp_state AmpState;

int power(int base, unsigned int exp) {
  int i, result = 1;
  for (i = 0; i < exp; i++) {
    result *= base;
  }
  return result;
}

void get_args(int *memory, int i_ptr, size_t count, int *return_args,
              char last_is_dest) {
  memcpy(return_args, &memory[i_ptr + 1], count * sizeof(int));

  int instruction_full = memory[i_ptr];

  // Mode math is easier when indexing from 1, so keep track of both here.
  for (int i = 0, j = 1; i < count; i++, j++) {
    // Get mode
    int mode = (instruction_full / power(10, j + 1)) % power(10, j);
    if (mode == 0) {
      // Position mode. Resolve pointer
      return_args[i] = memory[return_args[i]];
    }
    // Else immediate mode; arg is the value that we will use already.
  }

  // If the last argument is a destination value, undo us resolving the pointer
  if (last_is_dest) {
    return_args[count - 1] = memory[i_ptr + count];
  }
}

int run_intcode(int *og_program, size_t program_size, int *inputs) {
  int *memory;
  // Copy og_program
  memory = (int *)malloc(program_size * sizeof(int));
  memcpy(memory, og_program, program_size * sizeof(int));

  int input_idx = 0;
  int final_output = 0;

  int i_ptr = 0;
  while (i_ptr < program_size) {
    int instruction_full = memory[i_ptr];
    int instruction = instruction_full % 100;

    // Currently no instructions take more than 3 arguments.
    int args[3];

    // printf("Handling Opcode %d @ %d\n", instruction, i_ptr);
    switch (instruction) {
      case 1:
        // Add
        get_args(memory, i_ptr, 3, args, 1);

        memory[args[2]] = args[0] + args[1];

        // printf("  memory[%d] <- %d + %d = %d\n", args[2], args[0], args[1],
        // args[0] + args[1]);

        i_ptr += 4;
        break;
      case 2:
        // Multiply
        get_args(memory, i_ptr, 3, args, 1);

        memory[args[2]] = args[0] * args[1];

        // printf("  memory[%d] <- %d * %d = %d\n", args[2], args[0], args[1],
        // args[0] * args[1]);

        i_ptr += 4;
        break;
      case 3:
        // Store input
        get_args(memory, i_ptr, 1, args, 1);

        memory[args[0]] = inputs[input_idx++];

        // printf("  memory[%d] <- %d\n", args[0], memory[args[0]]);

        i_ptr += 2;
        break;
      case 4:
        // Produce output
        get_args(memory, i_ptr, 1, args, 0);

        // printf("OUTPUT: %d\n", args[0]);
        final_output = args[0];

        i_ptr += 2;
        break;
      case 5:
        // Jump if true
        get_args(memory, i_ptr, 2, args, 0);

        // printf("  if(%d) -> %d\n", args[0], args[1]);

        if (args[0]) {
          i_ptr = args[1];
        } else {
          i_ptr += 3;
        }

        break;
      case 6:
        // Jump if false
        get_args(memory, i_ptr, 2, args, 0);

        // printf("  if(!%d) -> %d\n", args[0], args[1]);

        if (!args[0]) {
          i_ptr = args[1];
        } else {
          i_ptr += 3;
        }

        break;
      case 7:
        // Less than
        get_args(memory, i_ptr, 3, args, 1);

        memory[args[2]] = args[0] < args[1];

        // printf("  memory[%d] <- %d < %d = %d\n", args[2], args[0], args[1],
        // args[0] < args[1]);

        i_ptr += 4;
        break;
      case 8:
        // Equals
        get_args(memory, i_ptr, 3, args, 1);

        memory[args[2]] = args[0] == args[1];

        // printf("  memory[%d] <- %d == %d = %d\n", args[2], args[0], args[1],
        // args[0] == args[1]);

        i_ptr += 4;
        break;
      case 99:
        free(memory);
        return final_output;
      default:
        printf("PLS TO HALP\n");
        return -1;
    }
  }
}

int run_intcode_until_output(AmpState *amp, int *inputs) {
  int *memory = amp->memory;
  int program_size = amp->program_size;

  int input_idx = 0;
  int final_output = 0;

  int i_ptr = amp->i_ptr;
  while (i_ptr < program_size) {
    int instruction_full = memory[i_ptr];
    int instruction = instruction_full % 100;

    // Currently no instructions take more than 3 arguments.
    int args[3];

    // printf("Handling Opcode %d @ %d\n", instruction, i_ptr);
    switch (instruction) {
      case 1:
        // Add
        get_args(memory, i_ptr, 3, args, 1);

        memory[args[2]] = args[0] + args[1];

        // printf("  memory[%d] <- %d + %d = %d\n", args[2], args[0], args[1],
        // args[0] + args[1]);

        i_ptr += 4;
        break;
      case 2:
        // Multiply
        get_args(memory, i_ptr, 3, args, 1);

        memory[args[2]] = args[0] * args[1];

        // printf("  memory[%d] <- %d * %d = %d\n", args[2], args[0], args[1],
        // args[0] * args[1]);

        i_ptr += 4;
        break;
      case 3:
        // Store input
        get_args(memory, i_ptr, 1, args, 1);

        memory[args[0]] = inputs[input_idx++];

        // printf("  memory[%d] <- %d\n", args[0], memory[args[0]]);

        i_ptr += 2;
        break;
      case 4:
        // Produce output
        get_args(memory, i_ptr, 1, args, 0);

        // printf("OUTPUT: %d\n", args[0]);

        i_ptr += 2;
        amp->i_ptr = i_ptr;
        amp->last_output = args[0];
        return args[0];
      case 5:
        // Jump if true
        get_args(memory, i_ptr, 2, args, 0);

        // printf("  if(%d) -> %d\n", args[0], args[1]);

        if (args[0]) {
          i_ptr = args[1];
        } else {
          i_ptr += 3;
        }

        break;
      case 6:
        // Jump if false
        get_args(memory, i_ptr, 2, args, 0);

        // printf("  if(!%d) -> %d\n", args[0], args[1]);

        if (!args[0]) {
          i_ptr = args[1];
        } else {
          i_ptr += 3;
        }

        break;
      case 7:
        // Less than
        get_args(memory, i_ptr, 3, args, 1);

        memory[args[2]] = args[0] < args[1];

        // printf("  memory[%d] <- %d < %d = %d\n", args[2], args[0], args[1],
        // args[0] < args[1]);

        i_ptr += 4;
        break;
      case 8:
        // Equals
        get_args(memory, i_ptr, 3, args, 1);

        memory[args[2]] = args[0] == args[1];

        // printf("  memory[%d] <- %d == %d = %d\n", args[2], args[0], args[1],
        // args[0] == args[1]);

        i_ptr += 4;
        break;
      case 99:
        amp->halted = 1;
        return 0;
      default:
        printf("PLS TO HALP\n");
        return -1;
    }
  }
}

int run_phase_sequence(AmpState *amps, int *og_memory, int *sequence,
                       size_t count, char support_looping) {
  // Reset the memory on each amp before simulating.
  for (int i = 0; i < count; i++) {
    memcpy(amps[i].memory, og_memory, amps[i].program_size * sizeof(int));
    amps[i].i_ptr = 0;
    amps[i].program_size = amps[i].program_size;
    amps[i].halted = 0;
    amps[i].last_output = 0;
  }

  if (support_looping) {
    int last_output = 0;
    int current_amp = 0;
    // First loop, pass in sequence and last_output
    for (int i = 0; i < count; i++) {
      int inputs[] = {sequence[i], last_output};
      last_output = run_intcode_until_output(&amps[i], inputs);
    }
    // Subsequent loops; only pass in last_output
    while (!amps[current_amp].halted) {
      int inputs[] = {last_output};
      last_output = run_intcode_until_output(&amps[current_amp], inputs);
      current_amp = ++current_amp % count;
    }
    return amps[count - 1].last_output;
  } else {
    int last_output = 0;
    for (int i = 0; i < count; i++) {
      int inputs[] = {sequence[i], last_output};
      last_output = run_intcode(amps[i].memory, amps[i].program_size, inputs);
    }
    return last_output;
  }
}

int encode_phase_sequence(int *values, size_t count) {
  int total = 0;
  for (int i = 0; i < count; i++) {
    total += values[i] * power(10, count - i - 1);
  }
  return total;
}

// Heap's algorithm
int find_best_permutation(AmpState *amps, int *og_memory, int *values,
                          size_t count, char support_looping) {
  int c[count];
  int best_values[count];
  memset(c, 0, count * sizeof(int));

  int max_output =
      run_phase_sequence(amps, og_memory, values, count, support_looping);
  int max_seq = encode_phase_sequence(values, count);

  int i = 0;
  int tmp;
  while (i < count) {
    if (c[i] < i) {
      if (i % 2 == 0) {
        tmp = values[0];
        values[0] = values[i];
        values[i] = tmp;
      } else {
        tmp = values[c[i]];
        values[c[i]] = values[i];
        values[i] = tmp;
      }
      int output =
          run_phase_sequence(amps, og_memory, values, count, support_looping);
      if (output > max_output) {
        max_output = output;
        max_seq = encode_phase_sequence(values, count);
        memcpy(best_values, values, count * sizeof(int));
      }

      c[i]++;
      i = 0;
    } else {
      c[i] = 0;
      i++;
    }
  }

  memcpy(values, best_values, count * sizeof(int));
  return max_output;
}

void part1(int *input, size_t input_size) {
  int amp_count = 5;
  AmpState amps[amp_count];
  for (int i = 0; i < amp_count; i++) {
    amps[i].memory = (int *)malloc(input_size * sizeof(int));
    memcpy(amps[i].memory, input, input_size * sizeof(int));

    amps[i].i_ptr = 0;
    amps[i].program_size = input_size;
    amps[i].halted = 0;
    amps[i].last_output = 0;
  }

  int values[] = {0, 1, 2, 3, 4};
  int best = find_best_permutation(amps, input, values, amp_count, 0);
  printf("Part 1: %d\n", best);

  for (int i = 0; i < amp_count; i++) {
    free(amps[i].memory);
  }
}

void part2(int *input, size_t input_size) {
  int amp_count = 5;
  AmpState amps[amp_count];
  for (int i = 0; i < amp_count; i++) {
    amps[i].memory = (int *)malloc(input_size * sizeof(int));
    memcpy(amps[i].memory, input, input_size * sizeof(int));

    amps[i].i_ptr = 0;
    amps[i].program_size = input_size;
    amps[i].halted = 0;
    amps[i].last_output = 0;
  }

  int values[] = {5, 6, 7, 8, 9};
  int best = find_best_permutation(amps, input, values, amp_count, 1);
  printf("Part 2: %d\n", best);

  for (int i = 0; i < amp_count; i++) {
    free(amps[i].memory);
  }
}

int main() {
  FILE *fptr;
  fptr = fopen("input.txt", "r");

  // First loop through file: find the file's size and the size of the intcode
  // array;
  char c;
  size_t array_size = 0;
  size_t file_size = 0;
  while (!feof(fptr)) {
    file_size++;
    c = fgetc(fptr);
    if (c == ',') {
      array_size++;
    }
  }
  array_size++;
  rewind(fptr);

  // Load the whole string into memory and then create the array of integers
  char input[file_size];
  fread(input, 1, file_size, fptr);

  int memory[array_size];
  int i = 0;
  char *token = strtok(input, ",");
  while (token != NULL) {
    memory[i++] = atoi(token);
    token = strtok(NULL, ",");
  }

  part1(memory, array_size);
  part2(memory, array_size);

  return 0;
}
