# [Day 21](https://adventofcode.com/2019/day/21)

This solution was done in Python, but relies on day 9's solution as the intcode computer. Run `g++ -o day9 ../09/day9.cpp` to compile the intcode computer, and then run `python day21.py part1_program.txt` to get the answers for part 1, or `python day21.py part2_program.txt` to get the answers for part 2.

To interact with this problem, I wrote a simple ASCII encoder/decoder script that interacts with the Intcode processor. I also had the encoder strip comments (prepended with `#`) so that I could keep notes in my solution files.  
I really liked solving these problems; it was fun working in a really small space and trying to come up with basic AI for the springdroid.
