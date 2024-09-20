class CreateBusinessUnits < ActiveRecord::Migration[7.0]
  def change
    create_table :business_units do |t|
      t.string :name

      t.timestamps
    end
  end
end
