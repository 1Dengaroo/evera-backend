# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_09_10_164814) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.string "city", null: false
    t.string "country", null: false
    t.string "line1", null: false
    t.string "line2"
    t.string "postal_code", null: false
    t.string "state", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "deliveries", force: :cascade do |t|
    t.string "email", null: false
    t.string "status", default: "manufacturing", null: false
    t.string "tracking_information"
    t.string "session_id", null: false
    t.uuid "order_id", null: false
    t.bigint "address_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "shipping_option", default: "Free Shipping", null: false
    t.integer "shipping_price", default: 0, null: false
    t.string "shipping_rate", default: "N/A", null: false
    t.index ["address_id"], name: "index_deliveries_on_address_id"
    t.index ["order_id"], name: "index_deliveries_on_order_id"
    t.index ["session_id"], name: "index_deliveries_on_session_id", unique: true
  end

  create_table "order_items", force: :cascade do |t|
    t.string "product_id", null: false
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "order_id"
    t.string "size"
    t.index ["product_id"], name: "index_order_items_on_product_id"
  end

  create_table "orders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email"
    t.string "checkout_session_id"
    t.boolean "paid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "subtotal"
    t.bigint "user_id"
    t.integer "amount_shipping"
    t.integer "amount_tax"
    t.string "shipping_code"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "products", id: :string, force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "price", null: false
    t.boolean "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "product_type", default: "unisex", null: false
    t.string "cover_image"
    t.text "sub_images", default: [], array: true
    t.string "sizes", default: ["XS", "S", "M", "L", "XL", "XXL"], array: true
    t.integer "quantity", default: 0
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "jti", null: false
    t.boolean "admin", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "deliveries", "addresses"
  add_foreign_key "deliveries", "orders"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "orders", "users"
end
