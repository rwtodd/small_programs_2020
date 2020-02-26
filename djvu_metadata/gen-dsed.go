package main

import (
	"bufio"
	"fmt"
	"io"
	"os"
	re "regexp"
	"strconv"
)

// the djvuPage defines a mapping from raw numeric pages to annotated names.
// the names take the form $prefix$num, where $prefix could be empty, and
// $num is considered missing on a -1
type djvuPage struct {
	page   int
	prefix string
	num    int
}

// Creates a string representation of an annotated page name, given
// a djvuPage.
func (p *djvuPage) pageName() string {
	if p.num < 0 {
		return p.prefix
	}
	return fmt.Sprintf("%s%d", p.prefix, p.num)
}

// Generates the next page, given a djvuPage. It increments the raw
// djvu page number, as well as the annotated page name's number. Pages
// following a non-numeric page $prefix are annotated as $prefix2'.
func (p *djvuPage) nextPage() djvuPage {
	newNum := p.num + 1
	if newNum <= 0 {
		newNum = 2
	}
	return djvuPage{p.page + 1, p.prefix, newNum}
}

// a bookMark maps a `name` with an annotated page name `$prefix$num`.  During
// processing, the bookmarks are further assocated with the matching `page` found
// in the `djvuPages`
type bookMark struct {
	name   string
	prefix string
	num    int
	page   int
}

var (
	rxComment = re.MustCompile(`^\s*$|^\s*#.*$`)
	rxMeta    = re.MustCompile(`(?i)^\s*META\s+([^:]+):\s*(.*)$`)
	rxDjvu    = re.MustCompile(`(?i)^\s*DJVU\s+(\d+)\s+(?:IS|=)(?:\s+BOOK)?\s+(\S*?)(\d*)\s*$`)
	rxMark    = re.MustCompile(`^\s*(\S*?)(\d*)\s+(.+)$`)

	metaData  = make(map[string]string)  // the matadata entries specified in the input
	djvuPages = make([]djvuPage, 0, 64)  // the djvu pages specified in the input
	marks     = make([]bookMark, 0, 128) // the bookmarks specified in the input
)

// matchBookmark takes a slice of `bookMark` and matches the front of the slice
// with the given `djvuPage`.  It returns the slice of remaining unmatched
// `bookMark`s.  Marks for raw djvu pages are matched to the raw page, during
// this process.
func matchBookmark(marks []bookMark, pg *djvuPage) []bookMark {
	if len(marks) == 0 {
		return nil
	} else if (marks[0].num == pg.num) && (marks[0].prefix == pg.prefix) {
		marks[0].page = pg.page
		return matchBookmark(marks[1:], pg)
	} else if marks[0].prefix == "" {
		marks[0].page = marks[0].num
		return matchBookmark(marks[1:], pg)
	} else {
		return marks
	}
}

// Produces `set-page-title` lines for every annotated djvu page in the document.
// Also, matches up bookmarks with the corresponding djvu pages as they pass by.
// Returns an error if not all bookmarks are matched.
func generateAllPages(out io.Writer) error {
	if len(djvuPages) == 0 {
		return nil
	}
	remainingMarks := marks
	for idx := 1; idx < len(djvuPages); idx++ {
		currentPage := djvuPages[idx-1]
		for currentPage.page < djvuPages[idx].page {
			fmt.Fprintf(out, "select %d; set-page-title %q\n", currentPage.page, currentPage.pageName())
			remainingMarks = matchBookmark(remainingMarks, &currentPage)
			currentPage = currentPage.nextPage()
		}
	}
	currentPage := djvuPages[len(djvuPages)-1]
	fmt.Fprintf(out, "select %d; set-page-title %q\n", currentPage.page, currentPage.pageName())
	remainingMarks = matchBookmark(remainingMarks, &currentPage)
	if remainingMarks != nil {
		return fmt.Errorf("Not all bookmarks matched... <%s>!", remainingMarks[0].name)
	}
	return nil
}

// Parses a single input line, saving off any important input data.  Returns an
// error if the input cannot be parsed.
func parseLine(s string) error {
	if rxComment.MatchString(s) {
	} else if m := rxMeta.FindStringSubmatchIndex(s); m != nil {
		metaData[s[m[2]:m[3]]] = s[m[4]:m[5]]
	} else if m := rxDjvu.FindStringSubmatchIndex(s); m != nil {
		pno, err := strconv.Atoi(s[m[2]:m[3]])
		if err != nil {
			return fmt.Errorf("djvu page in <%s> is not a number! (%v)", s, err)
		}
		bookPre, bookNum := s[m[4]:m[5]], -1
		if m[6] != m[7] {
			bookNum, err = strconv.Atoi(s[m[6]:m[7]])
			if err != nil {
				return fmt.Errorf("book page in <%s> is not a number! (%v)", s, err)
			}
		}
		djvuPages = append(djvuPages, djvuPage{pno, bookPre, bookNum})
	} else if m := rxMark.FindStringSubmatchIndex(s); m != nil {
		num := -1
		if m[4] != m[5] {
			var err error
			num, err = strconv.Atoi(s[m[4]:m[5]])
			if err != nil {
				return fmt.Errorf("mark page in <%s> is not a number! (%v)", s, err)
			}
		}
		marks = append(marks, bookMark{s[m[6]:m[7]], s[m[2]:m[3]], num, -1})
	} else {
		return fmt.Errorf("Bad input format <%s>!", s)
	}
	return nil
}

// Takes an input file $f, and writes $f.dsed with the djvused script code
// in it.
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
	outfname := os.Args[1] + ".dsed"
	fmt.Fprintf(os.Stderr, "Writing %s\n", outfname)
	outFile, err := os.Create(outfname)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error opening output file: %v\n", err)
		os.Exit(1)
	}
	defer outFile.Close()
	out := bufio.NewWriter(outFile)
	defer out.Flush()

	if err = generateAllPages(out); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
	// output metadata
	if len(metaData) > 0 {
		fmt.Fprintln(out, "select; set-meta")
		for key, val := range metaData {
			fmt.Fprintf(out, "%s\t%q\n", key, val)
		}
		fmt.Fprintln(out, ".")
	}
	// output bookmarks
	if len(marks) > 0 {
		fmt.Fprintln(out, "select; set-outline")
		fmt.Fprintln(out, "(bookmarks")
		for idx := range marks {
			fmt.Fprintf(out, " (%q \"#%d\")\n", marks[idx].name, marks[idx].page)
		}
		fmt.Fprintln(out, ")")
		fmt.Fprintln(out, ".")
	}
}
