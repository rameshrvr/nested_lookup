require_relative 'nested_lookup/version'
require_relative 'lookup_api'

# Include all supporting modules here
include NestedLookup
include LookUpApi

# module responsible for holding nested_lookup methods
module NestedLookup
  # Method to lookup a key in a deeply nested document
  #
  # @param document: Might be Array of Hashes (or)
  #   Hash of Arrays (or) Hash of array of hash etc...
  # @param key: Key to lookup
  # @param wild: Default disabled, enable it to
  #   perform case insensitive lookup
  # @param with_keys: Set to true will get the results with keys
  #
  # @return (with_keys set to false) Array of values
  #         (with_keys set to true) Hash of keys and values
  def nested_lookup(
      key, wild: false, with_keys: false
    )
    if with_keys
      result_hash = {}
      _nested_lookup(
        key: key, document: self,
        wild: wild, with_keys: with_keys
      ).each do |temp_hash|
        temp_hash.each do |hash_key, hash_value|
          if !(result_hash[hash_key.to_s])
            result_hash[hash_key.to_s] = [hash_value]
          else
            result_hash[hash_key.to_s].push(hash_value)
          end
        end
      end
      return result_hash
    end
    result_array = _nested_lookup(
      key: key, document: self, wild: wild,
      with_keys: with_keys
    )
    result_array
  end

  # Private method to lookup inside a document
  def _nested_lookup(
      key:, document:, wild: false,
      with_keys: false, result: []
    )
    if document.instance_of? Array
      document.each do |array_element|
        _nested_lookup(
          key: key, document: array_element,
          wild: wild, with_keys: with_keys,
          result: result
        )
      end
    elsif document.instance_of? Hash
      document.each do |hash_key, hash_value|
        if hash_key.to_s.eql?(key) || (
            wild && hash_key.to_s.downcase.include?(key.downcase)
          )
          if with_keys
            result.push("#{hash_key}": hash_value)
          else
            result.push(hash_value)
          end
        end
        if hash_value.instance_of? Array
          _nested_lookup(
            key: key, document: hash_value,
            wild: wild, with_keys: with_keys,
            result: result
          )
        elsif hash_value.instance_of? Hash
          _nested_lookup(
            key: key, document: hash_value,
            wild: wild, with_keys: with_keys,
            result: result
          )
        end
      end
    end
    result
  end

  # Method to get all keys from a nested dictionary as a List
  #
  # @param document: Might be Array of Hashes (or)
  #   Hash of Arrays (or) Hash of array of hash etc...
  #
  # @return Array of keys in the document
  #
  # Usage:
  # => document.get_all_keys() (or) document.get_all_keys
  def get_all_keys(
      result_array: []
    )
    if instance_of? Array
      each do |_element|
        _element.get_all_keys(result_array: result_array)
      end
    elsif instance_of? Hash
      each do |key, value|
        result_array.push(key.to_s)
        if value.instance_of? Hash
          value.get_all_keys(result_array: result_array)
        elsif value.instance_of? Array
          value.each do |arr_element|
            arr_element.get_all_keys(result_array: result_array)
          end
        end
      end
    end
    result_array
  end

  # Method to get occurrence of key in a deeply nested
  # document
  #
  # @param document: Deeply nested document
  # @param key: key name to look into the document
  #
  # @return Number of occurrence (Integer)
  def get_occurrence_of_key(key)
    _get_occurrence(document: self, item: 'key', keyword: key)
  end

  # Method to get occurrence of value in a deeply nested
  # document
  #
  # @param document: Deeply nested document
  # @param value: value name to look into the document
  #
  # @return Number of occurrence (Integer)
  def get_occurrence_of_value(value)
    _get_occurrence(document: self, item: 'value', keyword: value)
  end

  # Private method to get occurrence of key or value in deeply
  # nested document
  def _get_occurrence(
      document:, item:, keyword:
    )
    @result = 0
    @item = item
    @keyword = keyword
    def recrusion(document:)
      if document.instance_of? Hash
        if @item == 'key'
          @result += 1 if document.key?(@keyword.to_sym)
        elsif document.value?(@keyword)
          @result += document.values.count(@keyword)
        end
        document.each do |_key, value|
          if value.instance_of? Hash
            recrusion(document: value)
          elsif value.instance_of? Array
            value.each do |element|
              if element.eql? @keyword and @item.eql? 'value'
                @result += 1
              else
                recrusion(document: element)
              end
            end
          end
        end
      elsif document.instance_of? Array
        document.each do |element|
          recrusion(document: element)
        end
      end
    end
    recrusion(document: document)
    @result
  end
end
