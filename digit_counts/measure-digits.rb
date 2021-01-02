def histo(n)
  n.to_s.split('').group_by {|x| x}.transform_values {|x| x.size}
end

p histo(1038**931)
