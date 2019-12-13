#!/usr/bin/env awk -f

function translate_tile(tile_id) {
  if (tile_id == "0") {
    # Empty
    return "⬛️"
  } else if (tile_id == "1") {
    # Wall
    return "⬜️"
  } else if (tile_id == "2") {
    # Block
    return "🔷"
  } else if (tile_id == "3") {
    # Horizontal paddle
    return "🏓"
  } else if (tile_id == "4") {
    # Ball
    return "⚽️"
  } else {
    return tile_id
  }
}

function print_map(map, max_row, max_col, score) {
  # printf "min_row=%d, max_row=%d, min_col=%d, max_col=%d\n", min_row, max_row, min_col, max_col
  system("clear")
  block_count = 0
  for (r = 0; r <= max_row; r++) {
    for (c = 0; c <= max_col; c++) {
      # printf "%d,%d ", r, c
      if (map[r, c] == "2") {
        block_count++
      }
      printf "%s", translate_tile(map[r,c])
    }
    printf "\n"
  }
  printf "Score: %s; Number of blocks: %d\n", score, block_count
}

BEGIN {
  max_row = max_col = -1
  i = 0
  score = 0
}

{
  mod = i % 3
  if (mod == 0) {
    col = $0
    if (col > max_col || max_col == -1) {
      max_col = col
    }
  } else if (mod == 1) {
    row = $0
    if (row > max_row || max_row == -1) {
      max_row = row
    }
  } else {
    tile_id = $0
    if (col == "-1") {
      score = tile_id
    } else {
      map[row,col] = tile_id
    }
    print_map(map, max_row, max_col, score)
  }
  i++
}