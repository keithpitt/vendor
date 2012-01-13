class String

  def to_ascii_plist
    if length == 0
      "\"\""
    else
      # This is really fucking ugly. So the thing is, I hae no idea what
      # triggers quotes around string values in an ascii plist. If
      # anyone knows how, please let me know. I can't just put quotes
      # around everything, because for some reason, it doesn't work. So
      # as I find characters that seem to trigger quotes, I drop them in
      # here. Yes, this isn't a sustainable solution, but it works for
      # now.
      match(/\-|\s|\+|\<|\$|\"|\[|\=|\*|@|\,/) ? self.inspect : self
    end
  end

end
