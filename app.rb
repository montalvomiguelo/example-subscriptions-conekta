class App < Sinatra::Base
  set :method_override, true
  set :public_key, ENV['PUBLIC_KEY']
  enable :sessions

  helpers do
    def current_user
      @user ||= User[session[:id]]
    end

    def protected!
      return if current_user
      halt 401, 'Not authorized'
    end

    def create_conekta_customer
      @conekta_customer = Conekta::Customer.create({
        :name => current_user.name,
        :email => current_user.email,
        :phone => current_user.phone,
        :payment_sources => [{
          :type => 'card',
          :token_id => params[:conektaTokenId]
        }]
      })
    end
  end

  get '/products' do
    @products = Product.all
    erb :'products/index'
  end

  get '/products/new' do
    erb :'products/new'
  end

  post '/products' do
    product = Product.new
    product.name = params[:name]
    product.description = params[:description]
    product.secret = params[:secret]
    product.save

    redirect "/products/#{product.id}"
  end

  get '/products/:id' do
    @product = Product[params[:id]]
    erb :'products/show'
  end

  get '/products/:id/edit' do
    @product = Product[params[:id]]
    erb :'products/edit'
  end

  put '/products/:id' do
    @product = Product[params[:id]]
    @product.name = params[:name]
    @product.description = params[:description]
    @product.secret = params[:secret]
    @product.save
    redirect "/products/#{@product.id}"
  end

  delete '/products/:id' do
    Product[params[:id]].delete
    redirect '/products'
  end

  get '/register' do
    erb :'auth/register'
  end

  post '/register' do
    user = User.new
    user.name = params[:name]
    user.email = params[:email]
    user.phone = params[:phone]
    user.password = params[:password]
    user.save
    session[:id] = user.id
    redirect '/products'
  end

  get '/login' do
    erb :'auth/login'
  end

  post '/login' do
    user = User.first!(email: params[:email])
    halt 'Invalid credentials' unless user.password == params[:password]
    session[:id] = user.id
    redirect '/products'
  end

  get '/logout' do
    session.clear
  end

  get '/users/edit' do
    protected!
    erb :'users/edit'
  end

  put '/users/:id' do
    protected!
    current_user.name = params[:name] if params[:name]
    current_user.email = params[:email] if params[:email]
    current_user.phone = params[:phone] if params[:phone]
    current_user.password = params[:password] if params[:password]
    current_user.save
    redirect '/users/edit'
  end

  get '/subscription/new' do
    protected!
    erb :'subscriptions/new'
  end

  post '/subscription' do
    protected!

    @conekta_customer = current_user.conekta_customer

    unless @conekta_customer
      create_conekta_customer
      current_user.update(conekta_id: @conekta_customer['id'])
      current_user.update(card_last4: @conekta_customer['payment_sources'][0]['last4'])
      current_user.update(card_exp_month: @conekta_customer['payment_sources'][0]['exp_month'])
      current_user.update(card_exp_year: @conekta_customer['payment_sources'][0]['exp_year'])
      current_user.update(card_brand: @conekta_customer['payment_sources'][0]['brand'])
    end

    current_user.expires_at = nil if current_user.expires_at

    subscription = @conekta_customer.create_subscription(plan: 'plan-mensual')

    current_user.conekta_subscription_id = subscription['id']
    current_user.save

    @conekta_customer.inspect
  end

  get '/subscription/edit' do
    protected!
    erb :'subscriptions/edit'
  end

  put '/subscription' do
    protected!

    conekta_customer = current_user.conekta_customer

    begin
      card = conekta_customer.create_payment_source(type: 'card', token_id: params[:conektaTokenId])
    rescue Conekta::ErrorList => error_list
      for error_detail in error_list.details do
        puts error_detail.message
      end
    end

    conekta_customer.update(default_payment_source_id: card['id'])

    current_user.card_brand = card['brand']
    current_user.card_last4 = card['last4']
    current_user.card_exp_month = card['exp_month']
    current_user.card_exp_year = card['exp_year']
    current_user.save

    redirect '/users/edit'
  end

  delete '/subscription' do
    protected!

    conekta_customer = current_user.conekta_customer

    subscription = conekta_customer.subscription.cancel

    current_user.expires_at = Time.at(subscription['billing_cycle_end'])
    current_user.conekta_subscription_id = nil
    current_user.save


    redirect '/users/edit'
  end

end
