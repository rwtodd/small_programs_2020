# the script runs through every geomantic figure (65536 of them)
# and counts up the number of times the nephews, witnesses, and
# the judge take on each figure.  The judge table is printed at
# the end.

# this is pretty fast compared to the elisp version, and WAAY faster
# than the powershell version

$fig_names = {
    15 => "Via",
    14 => "Cauda Draconis",
    13 => "Puer",
    12 => "Fortuna Minor",
    11 => "Puella",
    10 => "Amissio",
    9  => "Carcer",
    8  => "Laetitia",
    7  => "Caput Draconis",
    6  => "Conjunctio",
    5  => "Acquisitio",
    4  => "Rubeus",
    3  => "Fortuna Major",
    2  => "Albus",
    1  => "Tristitia",
    0  => "Populus"
}

$judges = Hash.new 0

def add_figures(a,b)
  a ^ b
end

def line_of(fig, line)
  1 & (fig >> (4 - line))
end

def new_figure(lns)
  ((lns[0] << 3) | (lns[1] << 2) | (lns[2] << 1) | lns[3])
end

def new_sisters(moms)
  (1..4).map do |idx|
    new_figure( moms.map { |m| line_of(m, idx) } )
  end
end

def generate_shield(moms)
  sis = new_sisters moms
  neph = [ add_figures(moms[0], moms[1]),
           add_figures(moms[2], moms[3]),
           add_figures(sis[0], moms[1]),
           add_figures(sis[2], sis[3]) ]
  witness = [ add_figures(neph[2], neph[3]), add_figures(neph[0], neph[1]) ]
  judge = add_figures(witness[0], witness[1])
  $judges[$fig_names[judge]] += 1
end

16.times do |m1|
   16.times do |m2|
      16.times do |m3|
         16.times do |m4|
             generate_shield([m1,m2,m3,m4])
         end
      end
   end
end

p $judges
p $judges.values.sum
