Sequel.migration do
  change do
    alter_table(:users) do
      add_column :card_last4, String
      add_column :card_exp_month, String
      add_column :card_exp_year, String
      add_column :card_brand, String
    end
  end
end
