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
        if hash_key.to_s.eql?(key)
          @result = hash_value
        end
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
  def Get(key)
    _get(key: key, document: dup)
  end

  # Method to delete key from a deeply nested document
  #
  # @param document Might be Array of Hashes (or)
  #   Hash of Arrays (or) Hash of array of hash etc...
  # @param key: Key to delete
  #
  # @return Result document
  def Delete(key)
  	# Create deep copy of the object
  	temp = Marshal.load( Marshal.dump(self) )
  	temp.Delete!(key)
  end

  def Delete!(key)
    if instance_of? Array
      each do |array_element|
        array_element.Delete!(key)
      end
    elsif instance_of? Hash
      each do |hash_key, hash_value|
        if hash_key.to_s.eql?(key)
          delete(hash_key)
        else
          hash_value.Delete!(key)
        end
      end
    end
    self
  end

  # Method to update a key with the given value
  #
  # @param document Might be Array of Hashes (or)
  #   Hash of Arrays (or) Hash of array of hash etc...
  # @param key: Key to Update
  # @param value: Value to be updated
  #
  # @return Result document
  def Update(key:, value:)
  	# Create deep copy of the object
  	temp = Marshal.load( Marshal.dump(self) )
  	temp.Update!(key: key, value: value)
  end

  def Update!(key:, value:)
    if instance_of? Array
      each do |array_element|
        array_element.Update!(key: key, value: value)
      end
    elsif instance_of? Hash
      each do |hash_key, hash_value|
        if hash_key.to_s.eql?(key)
          self[hash_key] = value
        else
          hash_value.Update!(key: key, value: value)
        end
      end
    end
    self
  end
end
