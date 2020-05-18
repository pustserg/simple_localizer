require "minitest/autorun"

require_relative '../models/locale.rb'

class LocaleTest < Minitest::Test
  def test_parse
    yaml = {
      "ru" => {
        "messages" => {
          "hello" => "Привет"
        }
      }
    }
    locale = Locale.parse(yaml)

    assert locale.is_a?(Locale)
    assert_equal locale.language, 'ru'
    assert_equal locale.data.size, 1
    assert_equal locale.find_node_by_key('messages.hello').value, 'Привет'
  end

  def test_copy
    yaml = {
      "ru" => {
        "messages" => {
          "hello" => "Привет"
        }
      }
    }
    locale = Locale.parse(yaml)
    other_locale = locale.copy('de')

    assert other_locale.is_a?(Locale)
    assert_equal other_locale.language, 'de'
    assert_equal other_locale.data.size, 1

    node = other_locale.data.first
    assert_nil node.value
    assert_equal node.children.size, 1

    first_child = node.children.first
    assert first_child.children.empty?
    assert_equal first_child.value, 'Fill me'
  end

  def test_add_node
    locale = init_locale
    node = Node.new(key: 'bye', value: 'Пока', level: 2, parent_key: 'messages.bye')
    locale.add_node(node)

    assert_equal locale.find_node_by_key('messages.bye'), node
  end

  def init_locale
    yaml = {
      "ru" => {
        "messages" => {
          "hello" => "Привет"
        }
      }
    }
    Locale.parse(yaml)
  end
end
