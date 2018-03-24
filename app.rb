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
    erb :'subscriptions/new'
  end

end
