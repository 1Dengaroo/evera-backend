class AddFieldsToProducts < ActiveRecord::Migration[7.2]
  def change
    add_column :products, :product_type, :string, default: 'unisex', null: false
    add_column :products, :cover_image, :string
    add_column :products, :sub_images, :text, array: true, default: []
    add_column :products, :sizes, :string, array: true, default: ['XS', 'S', 'M', 'L', 'XL', 'XXL']
    add_column :products, :quantity, :integer, default: 0

    change_column_null :products, :name, false
    change_column_null :products, :price, false
    change_column_null :products, :active, false
  end
end
