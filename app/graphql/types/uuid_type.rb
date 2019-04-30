module Types
  class UuidType < Types::BaseScalar
    description 'A universally unique identifier (UUID) is a 128-bit number used to identify information in computer systems.'

    # @param [String] value
    # @return [String]
    def self.coerce_input(value, _ctx)
      value =~ /[a-f0-9]{8}-([a-f0-9]{4}-){3}[a-f0-9]{12}/ ? value : nil
    end

    # @param [String] value
    # @return [Date]
    def self.coerce_result(value, _ctx)
      value&.to_s
    end
  end
end
