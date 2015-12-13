module RubyDig
  def dig(key, *rest)
    value = self[key]
    if rest.empty? || value.nil?
      value
    elsif value.respond_to?(:dig)
      value.dig(*rest)
    end
  end
end

if RUBY_VERSION < '2.3'
  class Array
    include RubyDig
  end

  class Hash
    include RubyDig
  end
end
