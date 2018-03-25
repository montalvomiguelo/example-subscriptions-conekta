Sequel.migration do
  change do
    alter_table(:users) do
      add_column :conekta_id, String
      add_index :email
    end
  end
end
