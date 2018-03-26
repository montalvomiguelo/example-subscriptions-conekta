require 'test_helper'

class TestApp < Minitest::Test
  include Rack::Test::Methods

  def setup
    DatabaseCleaner.start

    @conekta_customer = Conekta::Customer.new
    @conekta_customer['id'] = 'cus_23'
    @conekta_customer['payment_sources'] = {
      0 => {
        'last4' => '4242',
        'exp_month' => '12',
        'exp_year' => '19',
        'brand' => 'VISA',
      }
    }

    @conekta_subscription = Conekta::Subscription.new
    @conekta_subscription['id'] = 'sub_23'


    @conekta_card = Conekta::Card.new
    @conekta_card['id'] = 'src_23'
    @conekta_card['last4'] = '4444'
    @conekta_card['brand'] = 'MC'
    @conekta_card['exp_month'] = '10'
    @conekta_card['exp_year'] = '20'
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

  def test_new_subscription_page
    user = create(:user, name: 'john doe', email: 'jd@aol.com', phone: '+52181818181', password: 'jd')
    env 'rack.session', { :id => user.id }
    get '/subscription/new'
    assert last_response.ok?
    assert last_response.body.include?('Tokenizar Tarjeta y Generar Cargo')
  end

  def test_creating_a_customer_with_conekta
    user = create(:user, name: 'john doe', email: 'jd@aol.com', phone: '+52181818181', password: 'jd')

    env 'rack.session', { :id => user.id }

    Conekta::Customer.expects(:create).returns(@conekta_customer)
    Conekta::Customer.any_instance.stubs(:create_subscription).returns(@conekta_subscription)

    post '/subscription', { :conektaTokenId => 'token' }

    user.refresh

    assert last_response.ok?
    assert_equal('cus_23', user.conekta_id)
  end

  def test_subscribing_a_user_in_conekta
    user = create(:user, name: 'john doe', email: 'jd@aol.com', phone: '+52181818181', password: 'jd')

    env 'rack.session', { :id => user.id }

    User.any_instance.stubs(:conekta_customer).returns(@conekta_customer)
    Conekta::Customer.any_instance.expects(:create_subscription).returns(@conekta_subscription)

    post '/subscription', { :conektaTokenId => 'token' }

    user.refresh

    assert last_response.ok?
    assert_equal('sub_23', user.conekta_subscription_id)
  end

  def test_show_product_secrent_only_for_subscribed_user
    user = create(:user, name: 'john doe', email: 'jd@aol.com', phone: '+52181818181', password: 'jd', conekta_subscription_id: 'sub_23', conekta_id: 'cus_23')

    env 'rack.session', { :id => user.id }

    product_name = 'Conekta Payments'
    product_secret = 'Secret video link here'
    product = create(:product, name: product_name, secret: product_secret)

    get "/products/#{product.id}"

    assert last_response.ok?
    assert last_response.body.include?(product_secret)

  end

  def test_persist_card_info
    user = create(:user, name: 'john doe', email: 'jd@aol.com', phone: '+52181818181', password: 'jd')

    env 'rack.session', { :id => user.id }

    Conekta::Customer.expects(:create).returns(@conekta_customer)
    Conekta::Customer.any_instance.stubs(:create_subscription).returns(@conekta_subscription)

    post '/subscription', { :conektaTokenId => 'token' }

    user.refresh

    assert last_response.ok?
    assert_equal('4242', user.card_last4)
    assert_equal('12', user.card_exp_month)
    assert_equal('19', user.card_exp_year)
    assert_equal('VISA', user.card_brand)

  end

  def test_edit_subscription_page
    user = create(:user, {
      name: 'john doe',
      email: 'jd@aol.com',
      phone: '+52181818181',
      password: 'jd',
      conekta_id: 'cus_23',
      card_last4: '4242',
      card_exp_month: '12',
      card_exp_year: '19',
      card_brand: 'VISA',
      conekta_subscription_id: 'sub_23',
    })

    env 'rack.session', { :id => user.id }

    get '/subscription/edit'

    assert last_response.ok?
    assert last_response.body.include?('Tokenizar Tarjeta y Actualizar Tarjeta')
  end

  def test_create_a_new_payment_source_in_conekta
    user = create(:user, {
      name: 'john doe',
      email: 'jd@aol.com',
      phone: '+52181818181',
      password: 'jd',
      conekta_id: 'cus_23',
      card_last4: '4242',
      card_exp_month: '12',
      card_exp_year: '19',
      card_brand: 'VISA',
      conekta_subscription_id: 'sub_23',
    })

    env 'rack.session', { :id => user.id }

    User.any_instance.stubs(:conekta_customer).returns(@conekta_customer)

    Conekta::Customer.any_instance.expects(:create_payment_source).returns(@conekta_card)

    @conekta_customer['default_payment_source_id'] = 'src_100'
    @conekta_customer['payment_sources'] = {
      0 => @conekta_card
    }

    Conekta::Customer.any_instance.stubs(:update).returns(@conekta_customer)

    put '/subscription', { :conektaTokenId => 'token' }
  end

  def test_update_default_user_payment_source_in_conekta
    user = create(:user, {
      name: 'john doe',
      email: 'jd@aol.com',
      phone: '+52181818181',
      password: 'jd',
      conekta_id: 'cus_23',
      card_last4: '4242',
      card_exp_month: '12',
      card_exp_year: '19',
      card_brand: 'VISA',
      conekta_subscription_id: 'sub_23',
    })

    env 'rack.session', { :id => user.id }

    User.any_instance.stubs(:conekta_customer).returns(@conekta_customer)

    Conekta::Customer.any_instance.stubs(:create_payment_source).returns(@conekta_card)

    @conekta_customer['default_payment_source_id'] = 'src_100'
    @conekta_customer['payment_sources'] = {
      0 => @conekta_card
    }

    Conekta::Customer.any_instance.expects(:update).returns(@conekta_customer)

    put '/subscription', { :conektaTokenId => 'token' }

    user.refresh

    assert_equal('4444', user.card_last4)
    assert_equal('MC', user.card_brand)
    assert_equal('10', user.card_exp_month)
    assert_equal('20', user.card_exp_year)
    follow_redirect!
  end

end
