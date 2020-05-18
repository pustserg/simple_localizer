class Node
  class << self
    def parse(data, level = 0, parent_key = '')
      key = data.keys.first
      child = data[key]
      next_level = level + 1
      next_parent_key = parent_key.empty? ? key : "#{parent_key}.#{key}"
      case child
      when Hash
        children = child.map { |(k, v)| parse({ k => v }, next_level, next_parent_key) }
        new(key: key, children: children, level: next_level, parent_key: next_parent_key)
      else
        new(key: key, value: child, level: level, parent_key: next_parent_key)
      end
    end
  end

  attr_reader :key, :level, :children, :parent_key
  attr_accessor :value

  def initialize(key:, children: [], value: nil, level: 0, parent_key: '')
    @key = key
    @level = level
    @value = value
    @children = children
    @parent_key = parent_key
  end

  def to_hash
    if parent?
      { key => children.map(&:to_hash).reduce(&:merge) }
    else
      { key => value }
    end
  end

  def copy_empty
    Node.new key: key,
             children: children.map(&:copy_empty),
             value: (parent? ? nil : 'Fill me'),
             level: level,
             parent_key: parent_key
  end

  def flat_children
    @flat_children ||= (children + children.map(&:flat_children)).flatten
  end

  def parent?
    value.nil? && !children.empty?
  end

  def child?
    !value.nil? && children.empty?
  end

  def add_child(node)
    children << node
    @flat_children = nil
  end

  def flat_parents
    [self, children.flat_map(&:flat_parents)]
  end
end
