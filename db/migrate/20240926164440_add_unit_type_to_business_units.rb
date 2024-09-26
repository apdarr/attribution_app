class AddUnitTypeToBusinessUnits < ActiveRecord::Migration[7.0]
  def change
    add_column :business_units, :unit_type, :integer, default: 0, null: false
  end
end
