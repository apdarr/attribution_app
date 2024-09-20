class CreateRepos < ActiveRecord::Migration[7.0]
  def change
    create_table :repos do |t|
      t.string :name
      t.string :business_unit
      t.string :property

      t.timestamps
    end
  end
end
