#!/usr/bin/env ruby

def cut(arr, n)
  if n < 0 then
    n = arr.size + n
  end
  return arr[n..-1] + arr[0..n-1]
end

def deal(arr, n)
  return_arr = []
  arr.each_index { |idx| return_arr[(idx * n) % arr.size] = arr[idx] }
  return return_arr
end

def process_input(input_file)
  lines = File.readlines(input_file)

  return lines.map do |line|
    case line
    when /deal into new stack/
      {
        type: 'reverse',
      }
    when /cut (-?\d+)/
      {
        type: 'cut',
        amount: $1.to_i
      }
    when /deal with increment (\d+)/
      {
        type: 'deal',
        amount: $1.to_i
      }
    end
  end
end

def minimize_input(processed, deck_size)
  minimized = []

  # "bubble down" all of the reverse functions by replacing each set of 2 lines (window) with one that ends with a reverse if possible
  # always pop from minimized before appending first+last since this window's first was previous window's last and we don't want accidental dupes
  # pop just returns nil on empty array so it's safe on first iteration
  processed.each do |second|
    first = minimized.pop

    unless first
      minimized << second
      next
    end

    if first[:type] == 'reverse' && second[:type] == 'reverse'
      # two reverses in a row is equivalent to a nop
      next
    end

    if second[:type] == 'reverse'
      # if just the second is a reverse, then this window is ordered how we like already. add to minimized
      minimized << first << second
    elsif first[:type] == 'reverse'
      if second[:type] == 'cut'
        modified_cut = {
          type: 'cut',
          amount: deck_size - second[:amount]
        }
        minimized << modified_cut << first
      elsif second[:type] == 'deal'
        special_cut = {
          type: 'cut',
          # amount: deck_size + 1 - second[:amount]
          amount: -(second[:amount] - 1)
        }
        minimized << second << special_cut << first
      end
    else
      # no reverses involved. pass along original input
      minimized << first << second
    end
  end

  # puts "MINIMIZED AFTER STEP 1:"
  # puts minimized

  # "bubble down" all of the cut functions using a method similar to above
  # don't bubble cuts past reverse since any reverse instruction would be at the end anyway because of the above loop
  processed = minimized
  minimized = []
  processed.each do |second|
    first = minimized.pop

    unless first
      minimized << second
      next
    end

    if first[:type] == 'cut' && second[:type] == 'cut'
      # combine the cuts
      combined_cut = {
        type: 'cut',
        amount: (first[:amount] + second[:amount]) % deck_size
      }
      minimized << combined_cut
    elsif second[:type] == 'cut' || second[:type] == 'reverse'
      # happy with the order
      minimized << first << second
    elsif first[:type] == 'cut'
      # second type is deal here
      modified_cut = {
        type: 'cut',
        amount: (first[:amount] * second[:amount]) % deck_size
      }
      minimized << second << modified_cut
    end
  end

  # puts "MINIMIZED AFTER STEP 2:"
  # puts minimized

  # bubbling is done; our current minimized should just start with some number of deal functions. combine them
  processed = minimized
  minimized = []
  processed.each do |second|
    first = minimized.pop

    unless first
      minimized << second
      next
    end

    if first[:type] == 'deal' && second[:type] == 'deal'
      combined_deal = {
        type: 'deal',
        amount: (first[:amount] * second[:amount]) % deck_size
      }
      minimized << combined_deal
    else
      minimized << first << second
    end
  end

  # puts "MINIMIZED AT END:"
  # puts minimized

  return minimized
end

def part1(processed_input, deck_size)
  deck = Array.new(deck_size) {|idx| idx}
  processed_input.each do |instruction|
    # puts line
    case instruction[:type]
    when 'reverse'
      deck.reverse!
    when 'cut'
      deck = cut(deck, instruction[:amount])
    when 'deal'
      deck = deal(deck, instruction[:amount])
    end
  end

  return deck.index(2019)
end

# this function and next: ty rosetta code
def extended_gcd(a, b)
  last_remainder, remainder = a.abs, b.abs
  x, last_x, y, last_y = 0, 1, 1, 0
  while remainder != 0
    last_remainder, (quotient, remainder) = remainder, last_remainder.divmod(remainder)
    x, last_x = last_x - quotient*x, x
    y, last_y = last_y - quotient*y, y
  end

  return last_remainder, last_x * (a < 0 ? -1 : 1)
end

def invmod(e, et)
  g, x = extended_gcd(e, et)
  if g != 1
    raise 'The maths are broken!'
  end
  x % et
end

def part2(processed_input, deck_size, answer_idx)
  # Since we know that the input for part2 is a deal, cut, and then reverse action,
  # we can be smart about processing these shuffles to only worry about the indices that affect
  # what ends up at position_for_answer
  deal, cut, _reverse = processed_input

  reversed_idx = deck_size - 1 - answer_idx
  cut_idx = (reversed_idx + cut[:amount]) % deck_size
  # deal_idx = (cut_idx * deal[:amount]) % deck_size
  deal_idx = (cut_idx * invmod(deal[:amount], deck_size)) % deck_size
  # deal_idx = (answer_idx * deal[:amount]) % deck_size
  # cut_idx = (deal_idx - cut[:amount]) % deck_size
  # reversed_idx = deck_size - 1 - cut_idx
  # return reversed_idx

  # Having just reverse-engineered the instructions, the element at deal_idx is the element that will end up at position_for_answer
  # Since these are space cards, the element at the index is equal to that index
  return deal_idx
end

input = process_input('input.txt')
input = minimize_input(input, 10007)
ans = part1(input, 10007)
puts "Part 1: #{ans}"

# Part 2: Make the n-times input
deck_size = 119315717514047
original_input = process_input('input.txt')
original_input = minimize_input(original_input, deck_size)

reps_remaining = 101741582076661
final_input = []
while reps_remaining > 0
  input = original_input
  doubles = Math::log(reps_remaining, 2).to_i
  # puts "Reps remaining: #{reps_remaining}; adding original input doubled #{doubles} times"
  doubles.times do
    input = minimize_input(input + input, deck_size)
  end
  final_input = minimize_input(final_input + input, deck_size)
  reps_remaining -= 2**doubles
end

ans = part2(final_input, deck_size, 2020)
puts "Part 2: #{ans}"
