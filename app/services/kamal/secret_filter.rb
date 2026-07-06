module Kamal
  class SecretFilter
    PATTERNS = [
      /password/i,
      /secret/i,
      /token/i,
      /key/i
    ].freeze

    def self.redact(text)
      text.to_s.lines.map do |line|
        if PATTERNS.any? { |pattern| line.match?(pattern) } && line.include?(":")
          key, _value = line.split(":", 2)
          "#{key}: [REDACTED]"
        else
          line
        end
      end.join
    end
  end
end
