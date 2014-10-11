xs = ARGF.readlines

header = []
ari    = []
nasi   = []
status = :header

xs.each do|x|
  case x
  when /;; okuri-ari entries/
    status = :ari
    next
  when /;; okuri-nasi entries/
    status = :nasi
    next
  end

  case status
  when :header
    header << x
  when :ari
    ari << x
  when :nasi
    nasi << x
  end
end

def print_each(xs)
  xs.each {|x| print x}
end

print_each header
puts ";; okuri-ari entries."
print_each ari.sort.reverse
puts ";; okuri-nasi entries."
print_each nasi.sort
