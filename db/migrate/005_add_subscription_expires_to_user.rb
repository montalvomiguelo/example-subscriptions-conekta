Sequel.migration do
  change do
    alter_table(:users) do
      add_column :expires_at, String
    end
  end
end
