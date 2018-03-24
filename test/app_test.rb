require 'test_helper'

class TestApp < Minitest::Test
  include Rack::Test::Methods

  def setup
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end

  def app
    App
  end

  def test_listing_products
    product_name = 'Conekta Payments Master Class'
    product = create(:product, name: product_name)
    get '/products'
    assert last_response.ok?
    assert last_response.body.include?(product_name)
  end

  def test_new_product_page
    get '/products/new'
    assert last_response.ok?
    assert last_response.body.include?('New Product')
  end

  def test_creating_a_product
    post '/products', { :name => 'Payments Class', :description => 'Learn how to use Conekta', :secret => 'Video link goes here' }
    assert_equal(1, Product.count)
    follow_redirect!
    assert last_response.body.include?('Payments Class')
  end

  def test_edit_product_page
    product_name = 'Conekta Payments'
    product = create(:product, name: product_name)
    get "/products/#{product.id}/edit"
    assert last_response.ok?
    assert last_response.body.include?(product_name)
  end

  def test_update_a_specific_product
    product_name = 'Conekta Payments'
    updated_name = 'Paypal Payments'
    updated_description = 'Paypal Master Class'
    updated_secret = 'Secret video link here'
    product = create(:product, name: product_name)
    put "/products/#{product.id}", { :name => updated_name, :description => updated_description, :secret =>  updated_secret }
    product.refresh
    assert_equal(updated_name, product.name)
    assert_equal(updated_description, product.description)
    assert_equal(updated_secret, product.secret)
    follow_redirect!
    assert last_response.body.include?(updated_name)
  end

  def test_delete_a_specific_product
    product_name = 'JS Course'
    product = create(:product, name: product_name)
    delete "/products/#{product.id}"
    assert_nil Product[product.id]
    follow_redirect!
    refute last_response.body.include?(product_name)
  end

  def test_registration_page
    get '/register'
    assert last_response.ok?
    assert last_response.body.include?('Register')
  end

  def test_creating_a_user
    post '/register', { :name => 'john doe', :email => 'jd@aol.com', :phone => '+52181818181', :password => 'jd' }
    assert_equal(1, User.count)
    follow_redirect!
  end

  def test_login_page
    get '/login'
    assert last_response.ok?
    assert last_response.body.include?('Login')
  end

  def test_logging_in_a_user
    user = create(:user, name: 'john doe', email: 'jd@aol.com', phone: '+52181818181', password: 'jd')
    post '/login', { :email => 'jd@aol.com', :password => 'jd' }
    assert_equal(user.id, last_request.env['rack.session']['id'])
    follow_redirect!
  end

  def test_logging_out_a_user
    user = create(:user, name: 'john doe', email: 'jd@aol.com', phone: '+52181818181', password: 'jd')
    env 'rack.session', { :id => user.id }
    get '/logout'
    assert_empty last_request.env['rack.session']
  end

  def test_edit_user_page
    user = create(:user, name: 'john doe', email: 'jd@aol.com', phone: '+52181818181', password: 'jd')
    env 'rack.session', { :id => user.id }
    get '/users/edit'
    assert last_response.ok?
    assert last_response.body.include?(user.name)
  end

  def test_update_a_specific_user
    user = create(:user, name: 'john doe', email: 'jd@aol.com', phone: '+52181818181', password: 'jd')
    env 'rack.session', { :id => user.id }
    put "/users/#{user.id}", { :name => 'juan doe' }
    user.refresh
    assert_equal('juan doe', user.name)
    follow_redirect!
  end
end
