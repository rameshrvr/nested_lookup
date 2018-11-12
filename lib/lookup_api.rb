# Module that holds methods Get, Delete, Update
module LookUpApi
  @result = nil
  # Private method to lookup inside a document
  def _get(key:, document:)
    if document.instance_of? Array
      document.each do |array_element|
        _get(key: key, document: array_element)
      end
    elsif document.instance_of? Hash
      document.each do |hash_key, hash_value|
        @result = hash_value if hash_key.to_s.eql?(key)
        _get(key: key, document: hash_value)
      end
    end
    # Return NIL if the key is not present in the document
    @result
  end

  # Method to get the value from a deeply nested document
  #
  # @param document Might be Array of Hashes (or)
  #   Hash of Arrays (or) Hash of array of hash etc...
  # @param key: Key to lookup
  #
  # @return Value if found else NULL
  def nested_get(key)
    _get(key: key, document: dup)
  end

  # Returns a document that includes everything but the given keys.
  #    document = { a: 1, b: 2, c: 3 }
  #    document.nested_delete('c') # => { a: 1, b: 2 }
  #    document # => { a: 1, b: 2, c: 3 }
  #
  # @param document Might be Array of Hashes (or)
  #   Hash of Arrays (or) Hash of array of hash etc...
  # @param key: Key to delete
  #
  # @return Result document
  def nested_delete(key)
    # Create deep copy of the object
    temp = Marshal.load(Marshal.dump(self))
    temp.nested_delete!(key)
  end

  # Replaces the document without the given keys.
  #    document = { a: 1, b: 2, c: 3 }
  #    document.nested_delete!('c') # => { a: 1, b: 2 }
  #    document # => { a: 1, b: 2 }
  #
  # @param document Might be Array of Hashes (or)
  #   Hash of Arrays (or) Hash of array of hash etc...
  # @param key: Key to delete
  #
  # @return self
  def nested_delete!(key)
    if instance_of? Array
      each do |array_element|
        array_element.nested_delete!(key)
      end
    elsif instance_of? Hash
      each do |hash_key, hash_value|
        if hash_key.to_s.eql?(key)
          delete(hash_key)
        else
          hash_value.nested_delete!(key)
        end
      end
    end
    self
  end

  # Returns a document that has updated key, value pair.
  #    document = { a: 1, b: 2, c: 3 }
  #    document.nested_update(key: 'c', value: 4) # => { a: 1, b: 2 , c: 4}
  #    document # => { a: 1, b: 2, c: 3 }
  #
  # @param document Might be Array of Hashes (or)
  #   Hash of Arrays (or) Hash of array of hash etc...
  # @param key: Key to Update
  # @param value: Value to be updated
  #
  # @return Result document
  def nested_update(key:, value:)
    # Create deep copy of the object
    temp = Marshal.load(Marshal.dump(self))
    temp.nested_update!(key: key, value: value)
  end

  # Replaces the document with the updated key, value pair.
  #    document = { a: 1, b: 2, c: 3 }
  #    document.nested_update!(key: 'c', value: 4) # => { a: 1, b: 2 , c: 4}
  #    document # => { a: 1, b: 2, c: 4 }
  #
  # @param document Might be Array of Hashes (or)
  #   Hash of Arrays (or) Hash of array of hash etc...
  # @param key: Key to Update
  # @param value: Value to be updated
  #
  # @return self
  def nested_update!(key:, value:)
    if instance_of? Array
      each do |array_element|
        array_element.nested_update!(key: key, value: value)
      end
    elsif instance_of? Hash
      each do |hash_key, hash_value|
        if hash_key.to_s.eql?(key)
          self[hash_key] = value
        else
          hash_value.nested_update!(key: key, value: value)
        end
      end
    end
    self
  end
end
