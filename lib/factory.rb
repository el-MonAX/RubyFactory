# frozen_string_literal: true

class Factory
  def self.new(*attributes, &block)
    class_name_from_string = attributes.shift.capitalize if attributes.first.is_a?(String)
    class_name = Class.new do
      attributes.each do |attribute|
        attr_accessor attribute
      end

      define_method :initialize do |*value|
        raise ArgumentError if value.length > attributes.length
        attributes.each_with_index do |attribute, index|
          instance_variable_set("@#{attribute}", value[index])
        end
      end

      def [](attribute)
        if attribute.is_a? Numeric
          raise IndexError unless instance_variables[attribute.floor]
          instance_variable_get("@#{members[attribute]}")
        elsif attribute.is_a? Float
          instance_variable_get("@#{members[attribute.to_i]}")
        else
          raise NameError unless members.include?(attribute.to_sym)
          instance_variable_get("@#{attribute}")
        end
      end

      def []=(attribute, value)
        if attribute.is_a? Integer
          raise IndexError unless instance_variables[attribute]
        end
        raise NameError unless instance_variable_get("@#{attribute}")
        instance_variable_set("@#{attribute}", value)
      end

      def dig(*args)
        to_h.dig(*args)
      end

      def each(&value)
        values.each(&value)
      end

      def each_pair(&name_value)
        to_h.each_pair(&name_value)
      end

      def eql?(other)
        hash.eql?(other.hash)
      end
      alias_method :==, :eql?

      def hash
        Hash[instance_variables.map { |name| [name.to_s.delete('@').to_sym, instance_variable_get(name)] }]
      end
      alias_method :to_h, :hash

      def length
        values.size
      end
      alias_method :size, :length

      def members
        instance_variables.map { |member| member.to_s.delete('@').to_sym }
      end

      def select(&member_value)
        values.select(&member_value)
      end

      def to_a
        instance_variables.map { |i| instance_variable_get(i) }
      end
      alias_method :values, :to_a

      def inspect
        super().delete('@')
      end
      alias_method :to_s, :inspect

      def values_at(*indexes)
        indexes.map do |index|
          raise IndexError unless instance_variables[index]
          to_a[index]
        end
      end

      class_eval(&block) if block_given?
    end
    const_set(class_name_from_string, class_name) if class_name_from_string
    class_name
  end
end
