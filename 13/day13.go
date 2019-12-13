package main

import (
	"fmt"
	"os/exec"
	"strings"
)

func main() {
	output, _ := exec.Command("./day9").CombinedOutput()

	m := make(map[string]string)

	var row, col, tileID string
	blockCount := 0
	for i, line := range strings.Split(strings.TrimSuffix(string(output), "\n"), "\n") {
		switch i % 3 {
		case 0:
			row = line
		case 1:
			col = line
		case 2:
			tileID = line
			key := fmt.Sprintf("%s,%s", row, col)
			m[key] = tileID
			if tileID == "2" {
				blockCount++
			}
		}
	}

	fmt.Printf("Part 1: %d\n", blockCount)
}
