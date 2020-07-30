.nr PS 12
.TL
Closed-Form Calendar Deltas
.AU
Richard Todd
.EQ
delim $$
.EN
.AB
.LP
The task at hand is to count the number of days between arbitrary dates,
which can span centuries, as part of a Discordian Calendar lua module.
Code I had found on the internet just looped across
years, checking for leap years on each iteration, which seemed overly
wasteful.
I wanted to explore the possibility of a more closed-form solution\(emor 
at least I hoped to avoid so much iteration\(emusing the Gregorian system for 
leap years. A derivation of a simple formula is outlined in this report.
.AE
.LP
Today's exploration is: how many days, $DELTA$, are between two arbitrary
dates? In writing a fun lua module for the Discordian Calendar, I had to write a
function to calculate the number of days until the \*QX-Day\*U, on
July 5\*{th\*}, 8661 (which is 1998 upside-down!). The code of the common
linux utility 
.B ddate
just loops through the years, checking for a leap year on every iteration,
and counting the days.  This is fast enough for one-off uses, but it made me
wonder how hard it would be to find a more closed-form solution.
.PP
This report derives a nice formula, step-by-step, which performs much
faster than the original code.
.SH
Formula Derivation
.LP
I denote dates by pairs $(y,d)$, where $y$ is the year and $d$ is the
day of the year (from 0 to 364, or 365 on leap years).  So, given a start
date $(y sub s , d sub s )$ and an end date $(y sub e , d sub e )$, what is
the fastest way to compute the number of days in the interval?
.PP
For a first estimate, I forget leap years, and also assume the days are
always Jan 1\*{st\*} on both ends. Then, the obvious solution
is: 
.\"
.EQ (1)
DELTA = 365 ( y sub e ~-~ y sub s )
.EN
.\"
.LP
Equation (1) gives a count that is too large by the number of days that
have already passed in $y sub s$, and too small by the count of days that
were not counted in $y sub e$.  Therefore, it's easy to add in those terms
to correct for the partial start and end years:
.EQ (2)
DELTA = 365 ( y sub e ~-~ y sub s ) ~+~ d sub e ~-~ d sub s
.EN
.LP
Equation (2) is accurate except that it doesn't account for the extra day
given to leap years.  Different calendars have used different schemes for
leap years, but I'll be using the Gregorian scheme here. A leap year is a year
that matches one of these two rules: 
.RS
.IP \(bu
the year is divisible by 4, but not by 100
.IP \(bu
the year is divisible by 400
.RE
.LP
So, I need to augment (2) with a correction term, $c$, which is
the number of leap years in the interval $[ y sub s , y sub e )$.
The exception for years divisible by 100 gets in the way of a simple formula,
so to avoid \f(CRif/then\fP logic, I reorganized the leap-year conditions into
three counts which I can combine to get the right number:
.RS
.IP \(bu
number of years divisible by 4 in the interval (call it $c sub 4$)
.IP \(bu
number of years divisible by 100 in the interval (call it $c sub 100$)
.IP \(bu
number of years divisible by 400 in the interval (call it $c sub 400$)
.RE
.LP
It's easy to see that the number of Gregorian leap years, $c$, can be given
by $c sub 4 - c sub 100 + c sub 400$.  In other words, if I can find a
closed-form way to compute those terms, the complete formula will be: 
.EQ (3)
DELTA = 365 ( y sub e ~-~ y sub s ) ~+~ d sub e ~-~ d sub s
~+~ c sub 4 ~-~ c sub 100 ~+~ c sub 400
.EN
.\"
.LP
I started with the $c sub 4$ term, which is the number of years divisible by
4 on the interval $[y sub s , y sub e )$.  Obviously one can get close with
integer division by 4, but that would be short by one in many cases (for
example, 2020 to 2025 is a span of 5 years, but contains two leap years). 
The first formula I could find was:
.EQ (4)
c sub 4 ~=~ 
    left floor { { y sub e ~-~ y sub s } over 4 } right floor
  ~+~ left ceil {   
      { ( y sub e ~-~ y sub s )~roman mod~4 ~-~ (-y sub s~roman mod~4) } over 4
    } right ceil
.EN
.LP
The term on the left is integer division, and the term on the right corrects
for the edge cases.  Happily, it turns out that this formula can be drastically
simplified.  First, I expanded the modulus operators into yet more floor
terms:
.EQ
c sub 4 ~=~ 
    left floor { { y sub e ~-~ y sub s } over 4 } right floor
  ~+~ left ceil {   
      { y sub e ~-~ y sub s ~-~ 4 ^
        left floor { { y sub e ~-~ y sub s } over  4 } right floor
        ~+~ y sub s + 4 ^ left floor { { -y sub s } over 4 } right floor 
      } over 4
    } right ceil
.EN
.LP
Then, I pulled the first term into the bigger ceiling computation:
.EQ
c sub 4 ~=~ 
    left ceil {   
      { 4 ^ left floor { { y sub e ~-~ y sub s } over 4 } right floor
       ~+~
        y sub e ~-~ y sub s ~-~ 4 ^
        left floor { { y sub e ~-~ y sub s } over  4 } right floor
        ~+~ y sub s + 4 ^ left floor { { -y sub s } over 4 } right floor 
      } over 4
    } right ceil
.EN
.LP
Now, I cancel out terms:
.EQ
c sub 4 ~=~ 
    left ceil {   
      {  y sub e ~+~ 4 ^ left floor { { -y sub s } over 4 } right floor } over 4
    } right ceil
.EN
.LP
Split into two fractions:
.EQ
c sub 4 ~=~ 
    left ceil {   
      y sub e over 4 ~+~ left floor { { -y sub s } over 4 } right floor
    } right ceil
.EN
.LP
Finally, I pulled apart the two terms and converted them both to ceiling form
for symmetry:
.EQ (5)
c sub 4 ~=~ left ceil { y sub e over 4 } right ceil
            ~-~
            left ceil { y sub s over 4 } right ceil
.EN
.LP
That's unbelievably simple compared to the original equation (4)! So much so,
that I wrote a test program to compare their results over a wide range of
inputs. Fortunately, they match.  Even more fortunately, $c sub 100$ and 
$c sub 400$ have exactly the same form, so I could jump directly to the short
form for those:
.EQ (6)
c sub 100 ~mark =~ left ceil { y sub e over 100 } right ceil
            ~-~
            left ceil { y sub s over 100 } right ceil
.EN
.EQ (7)
c sub 400 ~lineup =~ left ceil { y sub e over 400 } right ceil
            ~-~
            left ceil { y sub s over 400 } right ceil
.EN
.LP
The code I wrote (in lua, in this case), follows from equation (3) directly,
with the $c$-terms expanded out:
.RS
.nf
.ft CR
local ceil = math.ceil
local delta = (365 * (year_e - year_s) + day_e - day_s
        + ceil(year_e/4)   - ceil(year_s/4)
        - ceil(year_e/100) + ceil(year_s/100)
        + ceil(year_e/400) - ceil(year_s/400))
.ft P
.fi
.RE
.LP
This was a very satisfying exercise, and now I can compute results spanning
millennia with no loops in sight.
.\" vim: filetype=nroff:tw=77:noet:
