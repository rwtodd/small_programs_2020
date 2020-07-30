-- ensure that all my derived formulas are actually equivalent
function d1(a,b) 
  return math.floor((b-a)/4) + math.ceil(((b-a)%4 - (-a%4))/4)
end

function d2(a,b)
  return math.ceil(
     (4*math.floor((b-a)/4)   
       + b - a - 4*math.floor((b-a)/4) - (-a%4)
     )/4
  )
end

function d3(a,b)
  return math.ceil(
     (b - a - (-a%4))/4
  )
end

function d4(a,b)
  return math.ceil(
     (b + 4*math.floor(-a/4))/4
  )
end

function d5(a,b)
  return math.ceil(
     (b/4) + math.floor(-a/4)
  )
end

function d5(a,b)
  return math.ceil(b/4) + math.floor(-a/4)
end

function d6(a,b)
  return math.ceil(b/4) - math.ceil(a/4)
end

for a=1,100 do
  print(a)
  for b=a,100 do
	assert(d1(a,b)==d2(a,b))
	assert(d2(a,b)==d3(a,b))
	assert(d3(a,b)==d4(a,b))
	assert(d4(a,b)==d5(a,b))
	assert(d5(a,b)==d6(a,b))
  end
end
