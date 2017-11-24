# frozen_string_literal: true

# class Struct

class Factory
  def self.new(*attributes, &block)
    class_name_from_string = attributes.shift.capitalize if attributes.first.is_a?(String)
    clas = Class.new do
      attr_accessor *attributes
      # attributes.each do |attribute|
      #   attr_accessor attribute
      # end

      define_method :initialize do |*value|
        raise ArgumentError if value.length > attributes.length
        attributes.each_with_index do |attribute, index|
          instance_variable_set("@#{attribute}", value[index])
        end
      end

      def [](attribute)
        if attribute.is_a?(Integer) || attribute.is_a?(Float)
          raise IndexError unless instance_variables[attribute.floor]
          instance_variable_get("@#{members[attribute]}")
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
        # What if instance_variable_get returns nil?
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
        self.class == other.class && to_a == other.to_a
      end
      alias_method :==, :eql?

      def to_h
        members.each_with_object({}) do |name, hash|
          hash[name] = self[name]
        end
      end

      def length
        values.size
      end
      alias_method :size, :length

      define_method :members do
        attributes.map(&:to_sym)
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
    const_set(class_name_from_string, clas) if class_name_from_string
    clas
  end
end
