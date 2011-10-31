class String

  def to_ascii_plist
    if length == 0
      "\"\""
    else
      match(/\-|\s|\+|\<|\$|\"|\[|\=|\*|@/) ? self.inspect : self
    end
  end

end
