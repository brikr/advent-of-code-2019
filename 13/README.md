# [Day 13](https://adventofcode.com/2019/day/13)

This solution was done in Awk, but relies on day 9's solution as the intcode computer. Run `g++ -o day9 ../09/day9.cpp` to compile the intcode computer, and then run `./day9 | ./day13.awk` to play the game. The answer to part 1 is the number of blocks shown at the start, and the answer to part 2 is the score after winning the game.  
Part 2 of the problem requires changing the first value of the input. I've checked in the modified input file.

It takes a while to play the game, but it's possible to record your gameplay and replay parts of it when starting over:
```
touch inputs
# Playback inputs, then read from stdin
cat inputs - | tee inputs | ./day9 | ./day13.awk
# If you lose edit inputs to remove the last few inputs and start over
```
I also included the inputs to beat the game with my input. Run `cat bot | ./day9 | ./day13.awk` to play the game automatically.

This was a pretty interesting problem to solve. I had to slightly modify day 9's solution to flush stdout after each output so that Awk would definitely read them in time. Playing the game was sort of a pain, even once I setup a way to record my inputs. I bet I could have written a program that played the game on its own via a two-way pipe (just always move the paddle towards the column of the ball). Hell, with enough tinkering I probably could have modified the program to just spit out the total score of all blocks.
