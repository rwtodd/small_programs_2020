def histo(n)
  n.to_s.chars.group_by {|x| x}.transform_values! {|v| v.size}
end

p histo(1038**931)
