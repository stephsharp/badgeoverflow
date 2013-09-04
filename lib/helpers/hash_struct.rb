require 'ostruct'
require 'forwardable'

class HashStruct < OpenStruct
  def initialize(hash)
    super (@hash = hash)
  end

  extend Forwardable
  def_delegator :@hash, :[], :key
end
