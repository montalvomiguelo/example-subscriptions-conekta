class App < Sinatra::Base
  set :method_override, true

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
end
