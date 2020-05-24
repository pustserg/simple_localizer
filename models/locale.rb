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

  def copy(lang)
    Locale.new(lang, data.map(&:copy_empty))
  end

  def add_node(node)
    if node.parent_key.eql?('')
      add_node_to_top_level(node)
    else
      add_node_to_low_level(node)
    end
  end

  private

  def find_node_by_key(node_key, collection = data)
    all_nodes.find { |node| node.parent_key.eql?(node_key) }
  end

  def find_parent_by_key(node_key)
    parent_key = node_key.split('.')[0...-1].join('.')
    all_nodes.find { |node| node.key.eql?(parent_key) }
  end

  def add_node_to_top_level(node)
    data << node
  end

  def add_node_to_low_level(node)
    parent_node = find_parent_by_key(node.parent_key)
    return unless parent_node

    parent_node.add_child(node)
  end

  def all_nodes
    data.map { |n| [n, n.children].flatten}.flatten
  end
end
