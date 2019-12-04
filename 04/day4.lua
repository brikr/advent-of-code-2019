#!/usr/bin/lua5.3

min = 123257
max = 647015

function hasAdjacent(number)
  str = tostring(number)
  prev = str:sub(1,1)
  for i = 2, #str do
    curr = str:sub(i,i)
    if curr == prev then
      return true
    end
    prev = curr
  end
  return false
end

function hasSmallAdjacent(number)
  str = tostring(number)
  prev = str:sub(1,1)
  for i = 2, #str do
    curr = str:sub(i,i)
    if curr == prev then
      -- Two match; check the numbers around this pair to ensure they are different
      next = str:sub(i + 1, i + 1)
      if next == "" or curr ~= next then
        prevprev = str:sub(i - 2, i - 2)
        if prevprev == "" or curr ~= prevprev then
          return true
        end
      end
    end
    prev = curr
  end
  return false
end

function neverDecreases(number)
  str = tostring(number)
  prev = str:sub(1,1)
  for i = 2, #str do
    curr = str:sub(i,i)
    if curr < prev then
      return false
    end
    prev = curr
  end
  return true
end

-- Part 1
count = 0

for i = min,max
do
  if hasAdjacent(i) and neverDecreases(i) then
    count = count + 1
  end
end

print(count)

-- Part 2
count = 0

for i = min,max
do
  if hasSmallAdjacent(i) and neverDecreases(i) then
    count = count + 1
  end
end

print(count)