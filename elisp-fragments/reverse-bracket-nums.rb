# Here's a ruby version of the elisp, suitable for using as a filter
# from vim
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

def adjust(l)  # split the numbers and reverse them as a single hex number
  "0x" + l.split.reverse.join('')
end

ARGF.each_line do |line|
  line.match(%r!{([0-9A ]*)}!) do |m|
    line = m.pre_match + adjust(m.captures[0]) + m.post_match
  end
  puts line
end
