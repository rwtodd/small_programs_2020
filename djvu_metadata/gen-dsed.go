package main

import (
	"bufio"
	"fmt"
	"os"
	re "regexp"
)

var (
	rxComment = re.MustCompile(`^\s*$|^\s*#.*%`)
	rxMeta    = re.MustCompile(`(?i)^\s*META\s+([^:]+):\s*(.*)$`)
	rxDjvu    = re.MustCompile(`(?i)^\s*DJVU\s+(\d+)\s+(?:IS|=)(?:\s+BOOK)?\s+(\S*?)(\d*)\s*$`)
	rxMark    = re.MustCompile(`^\s*(\S*?)(\d*)\s+(.+)$`)

	metaData = make(map[string]string)
)

func parseLine(s string) error {
	if rxComment.MatchString(s) {
	} else if m := rxMeta.FindStringSubmatchIndex(s); m != nil {
		metaData[s[m[2]:m[3]]] = s[m[4]:m[5]]
	} else if m := rxDjvu.FindStringSubmatchIndex(s); m != nil {
	} else if m := rxMark.FindStringSubmatchIndex(s); m != nil {
	} else {
		return fmt.Errorf("Bad input format <%s>!", s)
	}
	fmt.Println(s)
	return nil
}

func main() {
	if len(os.Args) != 2 {
		fmt.Fprintln(os.Stderr, "Usage: gen-dsed infile")
		os.Exit(1)
	}

	// open the input...
	infl, err := os.Open(os.Args[1])
	if err != nil {
		fmt.Fprintf(os.Stderr, "Could not open input file <%s>!", os.Args[1])
		os.Exit(1)
	}
	defer infl.Close()

	// parse the file...
	line, scanner := 1, bufio.NewScanner(infl)
	for ; scanner.Scan(); line++ {
		if err = parseLine(scanner.Text()); err != nil {
			fmt.Fprintf(os.Stderr, "Line %d: %v\n", line, err)
			os.Exit(1)
		}
	}
	if err = scanner.Err(); err != nil {
		fmt.Fprintf(os.Stderr, "Line %d: %v\n", line, err)
		os.Exit(1)
	}

	// now produce the output
	fmt.Println(metaData)
}
