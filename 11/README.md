# [Day 11](https://adventofcode.com/2019/day/11)

This solution was done in Expect, but relies on day 9's solution as the intcode computer. Run `g++ -o day9 ../09/day9.cpp` to compile the intcode computer, and then run `expect day11.exp 0` for part 1, and `expect day11.exp 1` for part 2.

I'm really glad I setup the day9 intcode computer to communicate with stdin and stdout; I assumed it would come in handy. Nonetheless, this one was a wild ride. I spent an hour or so trying to setup a two-way pipe in a few languages with little luck, and then I remembered there was a fairly old language designed exactly for interacting via stdin/stdout with another program.  
Writing all of the logic in Tcl/Expect was quite challenging but I'm super happy it worked out.
