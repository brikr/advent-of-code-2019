# [Day 15](https://adventofcode.com/2019/day/15)

This solution was done in Dart, but relies on day 9's solution as the intcode computer. Run `g++ -o day9 ../09/day9.cpp` to compile the intcode computer, and then run `dart day15.dart` to get the answers.

Solving this problem once you have the maze mapped is pretty trivial, but I spent a decent amount of time trying to figure out how to get the maze going. At first, I was pondering how I'd do a search by controlling the robot the whole time, but then I realized I could just have the robot lazily map out the entire maze and I could handle the rest of the logic without interacting with the Intcode program.  
I've only worked with Dart a little bit in the past, but it seems like a cool and powerful language. Working with it here was pretty easy.
