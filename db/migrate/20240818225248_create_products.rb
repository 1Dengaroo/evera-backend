class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products, id: false do |t|
      t.string :id, primary_key: true
      t.string :name
      t.text :description
      t.decimal :price
      t.boolean :active

      t.timestamps
    end
  end
end
