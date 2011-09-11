class Array

  def to_ascii_plist
    "(\n#{map{ |x| x.to_ascii_plist + "," }.join("")}\n)"
  end

end
