def histo(n) {
  n.toString().collect().groupBy().collectEntries { k,v -> [k,v.size()] }
}

println histo(1127 ** 3921)
