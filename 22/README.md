# [Day 22](https://adventofcode.com/2019/day/22)

This solution was done in Ruby. Run `ruby day22.rb` to get the answers.

This problem was pretty insane (and it seems many people in the community didn't like the knowledge required to solve it efficiently). Huge thanks to [MegaGreenLightning's comment on Reddit](https://www.reddit.com/r/adventofcode/comments/ee56wh/2019_day_22_part_2_so_whats_the_purpose_of_this/fbr0vjb/). I had the idea of working backwards through the input to figure out which index would end up at `2020`, but I didn't know how to handle the number of times we would go through the input. Their comment helped me understand how it's feasible to combine all of the instructions into a much smaller input.
