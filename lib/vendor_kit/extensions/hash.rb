class Hash

  def to_ascii_plist
    inner = []
    each { |k, v| inner << "  #{k.to_s.to_ascii_plist} = #{v.to_ascii_plist};" }

    "{\n#{inner.join("\n")}\n}"
  end

end
