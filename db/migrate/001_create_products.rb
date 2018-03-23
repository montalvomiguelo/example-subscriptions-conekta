Sequel.migration do
  change do
    create_table(:products) do |t|
      primary_key :id
      String :name
      String :description, text: true
      String :secret, text: true
    end
  end
end
