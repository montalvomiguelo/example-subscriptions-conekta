class User < Sequel::Model
  plugin :validation_helpers

  def validate
    super
    validates_presence :name
    validates_presence :email
    validates_presence :phone
    validates_presence :password
  end

  def conekta_customer
    return Conekta::Customer.find(conekta_id) if conekta_id
  end

  attr_encrypted :password, key: 'This is a key that is 256 bits!!'
end
