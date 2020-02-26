# Djvu Metadata

This is a Go version of a script I have been using for some time
to help me set the metadata in .djvu documents.  Previously, I've
used everything from perl to clojure, but lately I've been doing
CLI programs in Go. 

## The Program

There are three things I like to add to my book scans, all accomplished by `djvused`:

 - Book metadata (title, authors, date)
 - Bookmarks for chapters
 - Page titles so the page numbers match what is printed on the book.

To help do this, I wrote a program that parses an input file like this one:

~~~~~~
# Comments are allowed
meta Title: The Title of the Book
meta Author: the Author
meta Date: 2019

# This maps djvu pages to book pages
# Books skip page numbers a LOT more often than you
# would think. And sometimes there are picture inserts,
# etc.  So, the program will number all the pages by 
# increasing the numeric part of the book page name
# (e.g. it will set 14 to 'p2' and 322 to 'pics2' even
# though I didn't write it down in the list below).
djvu 13 is book p1
djvu 113 is book p100
djvu 321 is book pics
djvu 325 is book p310
djvu 425 is book end

# Now I list the TOC like so... pages that are purely numeric
# map directly to djvu pages.  Otherwise, they are mapped according
# to the list above.
1 Cover
p1   Chapter 1
p40  Chapter 2
p65  Chapter 3
p125 Chapter 4
~~~~~~

I've written the program in several languages, as I often do.  There's clojure, java, 
raku, perl, powershell, haskell, and maybe more I'm forgetting all in the small programs 2019 repo.
Now in 2020 I use this go version.

