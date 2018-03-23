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
end
