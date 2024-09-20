class AddPrefixToBusinessUnits < ActiveRecord::Migration[7.0]
  def change
    add_column :business_units, :prefix, :string
  end
end
