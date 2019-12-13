#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
  long *memory;
  size_t size;

  long i_ptr;
  long r_base;
} Computer;

long power(long base, unsigned long exp) {
  long i, result = 1;
  for (i = 0; i < exp; i++) {
    result *= base;
  }
  return result;
}

void get_args(Computer *m, size_t count, long *return_args, char last_is_dest) {
  memcpy(return_args, &m->memory[m->i_ptr + 1], count * sizeof(long));

  long instruction_full = m->memory[m->i_ptr];

  // Mode math is easier when indexing from 1, so keep track of both here.
  for (int i = 0; i < count; i++) {
    // Get mode
    long mode = (instruction_full / power(10, i + 2)) % 10;
    switch (mode) {
      case 0:
        // Position mode. Resolve pointer
        if (i == count - 1 && last_is_dest) {
          // Don't resolve the pointer
        } else {
          return_args[i] = m->memory[return_args[i]];
        }
        break;
      case 1:
        // Immediate mode. Value is already what we want
        break;
      case 2:
        // Relative mode. Resolve relative pointer
        if (i == count - 1 && last_is_dest) {
          // Don't resolve the pointer
          return_args[i] += m->r_base;
        } else {
          return_args[i] = m->memory[return_args[i] + m->r_base];
        }
        break;
      default:
        printf("unexpected arg mode!\n");
    }
  }
}

void write_mem(Computer *m, long addr, long val) {
  if (addr >= m->size) {
    // Need to grow memory!
    // Double the current size, or grow to the new address, whichever makes the
    // program bigger
    m->size = ((m->size * 2) > addr) ? m->size * 2 : addr;

    m->memory = (long *)realloc(m->memory, m->size * sizeof(long));
  }
  m->memory[addr] = val;
}

long run_intcode(long *og_program, size_t program_size) {
  Computer comp;
  // Copy og_program
  comp.memory = (long *)malloc(program_size * sizeof(long));
  memcpy(comp.memory, og_program, program_size * sizeof(long));
  comp.size = program_size;
  comp.i_ptr = 0;
  comp.r_base = 0;

  while (comp.i_ptr < program_size) {
    long instruction_full = comp.memory[comp.i_ptr];
    long instruction = instruction_full % 100;

    // Currently no instructions take more than 3 arguments.
    long args[3];
    switch (instruction) {
      case 1:
        // Add
        get_args(&comp, 3, args, 1);

        write_mem(&comp, args[2], args[0] + args[1]);

        comp.i_ptr += 4;
        break;
      case 2:
        // Multiply
        get_args(&comp, 3, args, 1);

        write_mem(&comp, args[2], args[0] * args[1]);

        comp.i_ptr += 4;
        break;
      case 3:
        // Store input
        get_args(&comp, 1, args, 1);

        long input;
        scanf("%ld", &input);
        write_mem(&comp, args[0], input);

        comp.i_ptr += 2;
        break;
      case 4:
        // Produce output
        get_args(&comp, 1, args, 0);

        printf("%ld\n", args[0]);
        fflush(stdout);

        comp.i_ptr += 2;
        break;
      case 5:
        // Jump if true
        get_args(&comp, 2, args, 0);

        if (args[0]) {
          comp.i_ptr = args[1];
        } else {
          comp.i_ptr += 3;
        }

        break;
      case 6:
        // Jump if false
        get_args(&comp, 2, args, 0);

        if (!args[0]) {
          comp.i_ptr = args[1];
        } else {
          comp.i_ptr += 3;
        }

        break;
      case 7:
        // Less than
        get_args(&comp, 3, args, 1);

        write_mem(&comp, args[2], args[0] < args[1]);

        comp.i_ptr += 4;
        break;
      case 8:
        // Equals
        get_args(&comp, 3, args, 1);

        write_mem(&comp, args[2], args[0] == args[1]);

        comp.i_ptr += 4;
        break;
      case 9:
        // Adjust relative base
        get_args(&comp, 1, args, 0);

        comp.r_base += args[0];

        comp.i_ptr += 2;
        break;
      case 99:
        free(comp.memory);
        return 0;
      default:
        printf("unexpected instruction!\n");
        return -1;
    }
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

  // Load the whole string into memory and then create the array of longs
  char input[file_size];
  fread(input, 1, file_size, fptr);

  long memory[array_size];
  long i = 0;
  char *token = strtok(input, ",");
  while (token != NULL) {
    memory[i++] = atol(token);
    token = strtok(NULL, ",");
  }

  run_intcode(memory, array_size);

  return 0;
}
