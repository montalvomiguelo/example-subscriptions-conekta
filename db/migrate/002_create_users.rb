Sequel.migration do
  change do
    create_table(:users) do |t|
      primary_key :id
      String :name
      String :email
      String :phone
      String :encrypted_password
      String :encrypted_password_iv
    end
  end
end
