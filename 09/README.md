# [Day 9](https://adventofcode.com/2019/day/9)

This solution was done in C++. Run `g++ -o day9 day9.c` to compile, and then run `./day9` to start the machine. For part 1, enter `1` to see the answer; for part 2, enter `2` to see the answer.

Yet another intcode program, although part two hints that maybe this will be the last iteration of this machine. I chose C++ today since I could copy my C code from two days ago. I sort of cheated by only using valid C code for today's problem as well, although some parts probably would have been easier in C++ if I was familiar with it.

I made a few small modfications to clean up the code a little bit; and I also modified the program to use stdin/stdout for inputs/outputs. After seeing the amplifier problem two days ago, I realized that using actual streams for inputs/outputs would make chaining these computers a lot easier.
