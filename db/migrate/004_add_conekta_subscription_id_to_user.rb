Sequel.migration do
  change do
    alter_table(:users) do
      add_column :conekta_subscription_id, String
    end
  end
end
