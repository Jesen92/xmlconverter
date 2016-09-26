# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160926113641) do

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,          default: 0, null: false
    t.integer  "attempts",   limit: 4,          default: 0, null: false
    t.text     "handler",    limit: 4294967295,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "documents", force: :cascade do |t|
    t.string   "filename",      limit: 255
    t.string   "content_type",  limit: 255
    t.binary   "file_contents", limit: 65535
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "errors", force: :cascade do |t|
    t.integer  "usable_id",   limit: 4
    t.string   "usable_type", limit: 255
    t.text     "class_name",  limit: 65535
    t.text     "message",     limit: 65535
    t.text     "trace",       limit: 65535
    t.text     "target_url",  limit: 65535
    t.text     "referer_url", limit: 65535
    t.text     "params",      limit: 65535
    t.text     "user_agent",  limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "file_uploads", force: :cascade do |t|
    t.string   "document_file_name",    limit: 255
    t.string   "document_content_type", limit: 255
    t.integer  "document_file_size",    limit: 4
    t.datetime "document_updated_at"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  create_table "import_logs", force: :cascade do |t|
    t.integer  "zaglavlje_id", limit: 4
    t.integer  "user_id",      limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "seen",         limit: 4
    t.text     "message",      limit: 65535
  end

  create_table "joppds", force: :cascade do |t|
    t.integer  "stranica_a_id",         limit: 4
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "document_file_name",    limit: 255
    t.string   "document_content_type", limit: 255
    t.integer  "document_file_size",    limit: 4
    t.datetime "document_updated_at"
  end

  create_table "kupac_racuns", force: :cascade do |t|
    t.integer  "kupac_id",   limit: 4
    t.integer  "racun_id",   limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "kupac_zaglavljes", force: :cascade do |t|
    t.integer  "zaglavlje_id",          limit: 4
    t.integer  "kupac_id",              limit: 4
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "oznaka_poreznog_broja", limit: 4
  end

  create_table "kupacs", force: :cascade do |t|
    t.integer  "oznaka_poreznog_broja",     limit: 4
    t.string   "porezni_broj",              limit: 255
    t.string   "naziv_kupca",               limit: 255
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "zaglavlje_id",              limit: 4
    t.string   "pdv_identifikacijski_broj", limit: 255
    t.string   "ostali_brojevi",            limit: 255
    t.integer  "user_id",                   limit: 4
    t.boolean  "potvrdi_naziv"
  end

  create_table "opzstats", force: :cascade do |t|
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "document_file_name",    limit: 255
    t.string   "document_content_type", limit: 255
    t.integer  "document_file_size",    limit: 4
    t.datetime "document_updated_at"
    t.integer  "zaglavlje_id",          limit: 4
  end

  create_table "outputs", force: :cascade do |t|
    t.text     "za_output",  limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "racuns", force: :cascade do |t|
    t.string   "broj_izdanog_racuna",     limit: 255
    t.date     "datum_izdanog_racuna"
    t.date     "valuta_placanja_racuna"
    t.integer  "broj_dana_kasnjenja",     limit: 4
    t.decimal  "iznos_racuna",                        precision: 10, scale: 2
    t.decimal  "iznos_pdv",                           precision: 10, scale: 2
    t.decimal  "ukupan_iznos_racuna_pdv",             precision: 10, scale: 2
    t.decimal  "placeni_iznos_racuna",                precision: 10, scale: 2
    t.decimal  "neplaceni_dio_racuna",                precision: 10, scale: 2
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
    t.integer  "kupac_id",                limit: 4
    t.string   "porezni_broj_kupca",      limit: 255
    t.integer  "zaglavlje_id",            limit: 4
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255,   null: false
    t.text     "data",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "stjecateljs", force: :cascade do |t|
    t.string   "b4",         limit: 255
    t.string   "b5",         limit: 255
    t.integer  "b7_1",       limit: 4
    t.integer  "b7_2",       limit: 4
    t.integer  "b8",         limit: 4
    t.integer  "b9",         limit: 4
    t.integer  "b10",        limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "user_id",    limit: 4
    t.string   "b2",         limit: 255
    t.string   "b3",         limit: 255
    t.string   "b6_1",       limit: 255
    t.string   "b6_2",       limit: 255
  end

  create_table "stjecateljs_stranica_bs", force: :cascade do |t|
    t.integer  "stjecatelj_id", limit: 4
    t.integer  "stranica_b_id", limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "stranica_as", force: :cascade do |t|
    t.integer  "vrsta_izvjesca",        limit: 4
    t.string   "naziv",                 limit: 255
    t.string   "mjesto",                limit: 255
    t.string   "ulica",                 limit: 255
    t.string   "broj",                  limit: 255
    t.string   "email",                 limit: 255
    t.string   "oib",                   limit: 255
    t.string   "oznaka_podnositelja",   limit: 255
    t.integer  "user_id",               limit: 4
    t.boolean  "zakljucano_brisanje"
    t.boolean  "zakljucano_uredivanje"
    t.datetime "kreiran_xml"
    t.datetime "poslan_na_poreznu"
    t.integer  "stranica_b_id",         limit: 4
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  create_table "stranica_bs", force: :cascade do |t|
    t.date     "b10_1"
    t.date     "b10_2"
    t.decimal  "b11",                     precision: 10, scale: 2
    t.decimal  "b12",                     precision: 10, scale: 2
    t.decimal  "b12_1",                   precision: 10, scale: 2
    t.decimal  "b12_2",                   precision: 10, scale: 2
    t.decimal  "b12_3",                   precision: 10, scale: 2
    t.decimal  "b12_4",                   precision: 10, scale: 2
    t.decimal  "b12_5",                   precision: 10, scale: 2
    t.decimal  "b12_6",                   precision: 10, scale: 2
    t.decimal  "b12_7",                   precision: 10, scale: 2
    t.decimal  "b12_8",                   precision: 10, scale: 2
    t.decimal  "b12_9",                   precision: 10, scale: 2
    t.decimal  "b13_1",                   precision: 10, scale: 2
    t.decimal  "b13_2",                   precision: 10, scale: 2
    t.decimal  "b13_3",                   precision: 10, scale: 2
    t.decimal  "b13_4",                   precision: 10, scale: 2
    t.decimal  "b13_5",                   precision: 10, scale: 2
    t.decimal  "b14_1",                   precision: 10, scale: 2
    t.decimal  "b14_2",                   precision: 10, scale: 2
    t.integer  "b15_1",         limit: 4
    t.decimal  "b15_2",                   precision: 10, scale: 2
    t.integer  "b16_1",         limit: 4
    t.decimal  "b16_2",                   precision: 10, scale: 2
    t.decimal  "b17",                     precision: 10, scale: 2
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.integer  "stranica_a_id", limit: 4
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "name",                   limit: 255
    t.string   "surname",                limit: 255
    t.string   "tel",                    limit: 255
    t.string   "fax",                    limit: 255
    t.string   "role",                   limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      limit: 255,        null: false
    t.integer  "item_id",        limit: 4,          null: false
    t.string   "event",          limit: 255,        null: false
    t.string   "whodunnit",      limit: 255
    t.text     "object",         limit: 4294967295
    t.datetime "created_at"
    t.text     "object_changes", limit: 65535
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "zaglavljes", force: :cascade do |t|
    t.date     "datum_od"
    t.date     "datum_do"
    t.string   "naziv",                         limit: 255
    t.string   "mjesto",                        limit: 255
    t.string   "ulica",                         limit: 255
    t.string   "broj",                          limit: 255
    t.string   "email",                         limit: 255
    t.date     "na_dan"
    t.date     "nisu_naplaceni_do"
    t.datetime "created_at",                                                         null: false
    t.datetime "updated_at",                                                         null: false
    t.integer  "oib",                           limit: 8
    t.decimal  "opz_ukupan_iznos_racuna_s_pdv",             precision: 10, scale: 2
    t.decimal  "opz_ukupan_iznos_pdv",                      precision: 10, scale: 2
    t.integer  "user_id",                       limit: 4
    t.datetime "kreiran_xml"
    t.datetime "poslan_na_poreznu"
    t.string   "korisnik_preuzeo_xml",          limit: 255
    t.string   "korisnik_porezna",              limit: 255
    t.boolean  "zakljucano_brisanje"
    t.boolean  "zakljucano_uredivanje"
    t.boolean  "created"
  end

end
