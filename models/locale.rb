require_relative './node.rb'

class Locale
  NodeNotFound = Class.new(ArgumentError)
  NodeIsParentNotValue = Class.new(ArgumentError)

  class << self
    def parse(yaml_hash)
      lang = yaml_hash.keys.first
      data = yaml_hash[lang].map { |(k, v)| Node.parse({ k => v }) }
      new(lang, data)
    end
  end

  attr_reader :language, :data

  def initialize(language, data)
    @language = language
    @data = data
  end

  def to_hash
    {
      language => data.map(&:to_hash).reduce(&:merge)
    }
  end

  def change_node_value(node_key, val)
    change_node = find_node_by_key(node_key)
    if change_node.nil?
      raise NodeNotFound
    elsif change_node.parent?
      raise NodeIsParentNotValue
    else
      change_node.value = val
    end
  end

  def find_node_by_key(node_key, collection = data)
    flat_nodes.find { |node| node.parent_key.eql?(node_key) }
  end

  def copy(lang)
    Locale.new(lang, data.map(&:copy_empty))
  end

  private

  def flat_nodes
    @flat_nodes ||= data.flat_map(&:flat_children)
  end
end
