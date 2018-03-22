require 'test_helper'

class TestApp < Minitest::Test
  include Rack::Test::Methods

  def app
    App
  end

  def test_it_says_hello_world
    get '/'
    assert last_response.ok?
    assert_equal 'Hello World', last_response.body
  end
end
