#!/usr/bin/env python

from subprocess import PIPE, Popen
import sys


def main():
    if (len(sys.argv) < 2):
        print('No program provided.')
        return

    processed_program = ''
    with open(sys.argv[1]) as f:
        for line in f:
            statement = line.split('#')[0].strip()
            processed_program += statement + '\n'

    proc = Popen(['./day9'], stdin=PIPE, stdout=PIPE)

    ascii_ints = []
    for char in processed_program:
        ascii_ints.append(str(ord(char)))
    ascii_program = '\n'.join(ascii_ints)

    encoded_stdout = proc.communicate(input=ascii_program.encode())[0].decode()

    decoded_stdout = ''
    for line in encoded_stdout.splitlines():
        if (int(line) < 255):
            decoded_stdout += chr(int(line))
        else:
            answer = line

    print(decoded_stdout)
    print("Success! Answer is: " + answer)


if __name__ == "__main__":
    main()
