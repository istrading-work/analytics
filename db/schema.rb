# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161118025450) do

  create_table "a_admin_users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "admin",                  default: false
    t.boolean  "partner",                default: false
    t.index ["email"], name: "index_a_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_a_admin_users_on_reset_password_token", unique: true
  end

  create_table "a_crm_delivery_types", id: false, force: :cascade do |t|
    t.string   "code",       null: false
    t.string   "name"
    t.boolean  "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_a_crm_delivery_types_on_code", unique: true
  end

  create_table "a_crm_histories", force: :cascade do |t|
    t.datetime "dt"
    t.integer  "a_crm_order_id"
    t.string   "a_crm_status_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.datetime "last_updated_at"
    t.index ["a_crm_order_id"], name: "index_a_crm_histories_on_a_crm_order_id"
    t.index ["a_crm_status_id"], name: "index_a_crm_histories_on_a_crm_status_id"
  end

  create_table "a_crm_orders", id: false, force: :cascade do |t|
    t.integer  "id",                                              null: false
    t.string   "num"
    t.decimal  "summ",                   precision: 15, scale: 2
    t.datetime "dt"
    t.datetime "dt_status_updated"
    t.decimal  "delivery_cost",          precision: 15, scale: 2
    t.decimal  "delivery_net_cost",      precision: 15, scale: 2
    t.string   "a_crm_status_id"
    t.string   "a_crm_shop_id"
    t.string   "a_crm_delivery_type_id"
    t.integer  "a_crm_user_id"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.index ["a_crm_delivery_type_id"], name: "index_a_crm_orders_on_a_crm_delivery_type_id"
    t.index ["a_crm_shop_id"], name: "index_a_crm_orders_on_a_crm_shop_id"
    t.index ["a_crm_status_id"], name: "index_a_crm_orders_on_a_crm_status_id"
    t.index ["a_crm_user_id"], name: "index_a_crm_orders_on_a_crm_user_id"
    t.index ["id"], name: "index_a_crm_orders_on_id", unique: true
  end

  create_table "a_crm_shops", id: false, force: :cascade do |t|
    t.string   "code",       null: false
    t.string   "name"
    t.boolean  "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_a_crm_shops_on_code", unique: true
  end

  create_table "a_crm_status_groups", id: false, force: :cascade do |t|
    t.string   "code",       null: false
    t.string   "name"
    t.boolean  "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_a_crm_status_groups_on_code", unique: true
  end

  create_table "a_crm_statuses", id: false, force: :cascade do |t|
    t.string   "code",         null: false
    t.string   "name"
    t.boolean  "is_active"
    t.string   "crm_group_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["code"], name: "index_a_crm_statuses_on_code", unique: true
    t.index ["crm_group_id"], name: "index_a_crm_statuses_on_crm_group_id"
  end

  create_table "a_crm_users", id: false, force: :cascade do |t|
    t.integer  "id",         null: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.boolean  "is_manager"
    t.boolean  "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id"], name: "index_a_crm_users_on_id", unique: true
  end

  create_table "a_status_groups", force: :cascade do |t|
    t.string "name", null: false
    t.index ["name"], name: "index_a_status_groups_on_name", unique: true
  end

  create_table "a_status_links", force: :cascade do |t|
    t.string  "a_crm_status_id",   null: false
    t.integer "a_status_group_id", null: false
    t.index ["a_crm_status_id"], name: "index_a_status_links_on_a_crm_status_id"
    t.index ["a_status_group_id"], name: "index_a_status_links_on_a_status_group_id"
  end

  create_table "a_syncs", force: :cascade do |t|
    t.string   "kind"
    t.integer  "page"
    t.integer  "total_pages"
    t.boolean  "status"
    t.integer  "a_crm_order_id"
    t.integer  "order_index"
    t.integer  "total_orders"
    t.integer  "total_changed"
    t.boolean  "done"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["a_crm_order_id"], name: "index_a_syncs_on_a_crm_order_id"
  end

  create_table "a_user_shops", force: :cascade do |t|
    t.integer "a_admin_user_id", null: false
    t.string  "a_crm_shop_id",   null: false
    t.index ["a_admin_user_id"], name: "index_a_user_shops_on_a_admin_user_id"
    t.index ["a_crm_shop_id"], name: "index_a_user_shops_on_a_crm_shop_id"
  end

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.string   "author_type"
    t.integer  "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

end
