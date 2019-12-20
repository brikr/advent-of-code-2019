package main

import (
	"bytes"
	"fmt"
	"os/exec"
	"strings"
)

func main() {
	// for y := 0; y < 50; y++ {
	// 	for x := 0; x < 50; x++ {
	// 		if isPulled(x, y) {
	// 			fmt.Print("#")
	// 			count++
	// 		} else {
	// 			fmt.Print(".")
	// 		}
	// 	}
	// 	fmt.Println()
	// }

	fmt.Printf("Part 1: %d\n", part1())
	x, y := part2()
	fmt.Printf("Part 2: %d\n", x*10000+y)

	// Visualize the rows that can hold the square
	// prevStartX := x - 100
	// for i := y - 2; i < y+102; i++ {
	// 	fmt.Printf("%5d ", i)
	// 	startX, endX := getRowFast(i, prevStartX)
	// 	for j := x - 100; j < startX; j++ {
	// 		fmt.Print(".")
	// 	}
	// 	for j := startX; j <= endX; j++ {
	// 		fmt.Print("#")
	// 	}
	// 	for j := endX + 1; j < endX+100; j++ {
	// 		fmt.Print(".")
	// 	}
	// 	fmt.Println()
	// }
}

func part1() int {
	count := 0
	prevStartX := 0
	for y := 0; y < 50; y++ {
		startX, endX := getRowFast(y, prevStartX)
		prevStartX = startX

		count += endX - startX + 1
	}
	return count
}

// returns x, y of answer
func part2() (int, int) {
	// Step 1: Find a row that is slightly less than 100 units wide (rough starting point for a sequential search)
	yPast100 := 1
	prevStartX := 0
	// Double row number until we reach a row that is greater than 100 units wide
	for {
		startX, endX := getRowFast(yPast100, prevStartX)
		prevStartX = startX
		if (endX - startX + 1) > 100 {
			break
		}
		yPast100 *= 2
	}
	// Exponentially subtract from yPast100 until we are under 100 (in case we went so far past 100 that we missed an important row)
	yDelta := -1
	for {
		y := yPast100 + yDelta
		startX, endX := getRowFast(y, prevStartX-10) // Really rough startXMin, but it should work
		prevStartX = startX
		if (endX - startX + 1) < 100 {
			break
		}
		yDelta *= 2
	}

	y := yPast100 + yDelta
	// fmt.Printf("Good starting row: %d\n", y)

	// Step 2: Keep track of the end of the last 100 rows that we've measured. Go until we find the first row such that 100AgoEndX - thisStartX > 100
	// When we do, the answer is x=thisStartX, y=100AgoY
	var endXHistory [100]int
	// Fill history (I'm pretty sure these first 100 rows won't have our answer)
	for i := 0; i < 100; i++ {
		idx := y % 100
		prevStartX, endXHistory[idx] = getRowFast(y, prevStartX)
		y++
	}
	// fmt.Println("endXHistory is filled")

	// Find the answer
	for {
		startX, endX := getRowFast(y, prevStartX)
		prevStartX = startX

		hundredTallWidth := endXHistory[(y+1)%100] - startX + 1
		// fmt.Printf("y=%d, startX=%d, endX=%d, 100TallWidth=%d\n", y, startX, endX, hundredTallWidth)

		if hundredTallWidth >= 100 {
			return startX, y - 100
		}

		endXHistory[y%100] = endX
		y++
	}
}

func isPulled(x int, y int) bool {
	cmd := exec.Command("./day9")

	input := fmt.Sprintf("%d\n%d", x, y)
	buffer := bytes.Buffer{}
	buffer.Write([]byte(input))

	cmd.Stdin = &buffer

	outputBytes, _ := cmd.CombinedOutput()
	output := strings.TrimSpace(string(outputBytes))

	return output == "1"
}

// Returns startX, endX
func getRowFast(y int, startXMin int) (int, int) {
	// fmt.Printf("y=%d, startXMin=%d\n", y, startXMin)
	// since we have visualized the beam, we know that y = (1, 2, or 4) has no pull. special case it since this algo breaks otherwise
	if y == 1 || y == 2 || y == 4 {
		return 0, -1 // makes our count math return 0 pulls
	}
	// sequentially find xLo
	xLo := startXMin
	for !isPulled(xLo, y) {
		xLo++
		// fmt.Printf("  xLo is now %d\n", xLo)
	}
	startX := xLo

	// quickly find hi
	xHi := xLo
	for isPulled(xHi, y) {
		if xHi == 0 {
			xHi = 1
		} else {
			xHi *= 2
		}
		// fmt.Printf("  xHi is now %d\n", xHi)
	}

	// fmt.Printf("y=%d; xLo is %d; xHi is %d\n", y, xLo, xHi)

	// Binary search for a pulled location followed by a not pulled location
	for xLo <= xHi {
		xMid := (xLo + xHi) / 2
		if !isPulled(xMid, y) {
			// End is to the left. Peep one to the left to see if we've found answer
			if isPulled(xMid-1, y) {
				return startX, xMid - 1
			}
			// Otherwise, adjust xHi
			xHi = xMid - 1
		} else {
			// End is to the right or is this element. Peep one to the right to see if we've found answer
			if !isPulled(xMid+1, y) {
				return startX, xMid
			}
			// Otherwise, adjust xLo
			xLo = xMid + 1
		}
	}

	fmt.Printf("y=%d found a strange row. This should never happen!\n", y)
	return 0, -1
}
