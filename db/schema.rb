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

ActiveRecord::Schema.define(version: 20160212162159) do

  create_table "kupacs", force: :cascade do |t|
    t.integer  "oznaka_poreznog_broja", limit: 4
    t.string   "porezni_broj",          limit: 255
    t.string   "naziv_kupca",           limit: 255
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "zaglavlje_id",          limit: 4
  end

  create_table "racuns", force: :cascade do |t|
    t.string   "broj_izdanog_racuna",     limit: 255
    t.date     "datum_izdanog_racuna"
    t.date     "valuta_placanja_racuna"
    t.integer  "broj_dana_kasnjenja",     limit: 4
    t.decimal  "iznos_racuna",                        precision: 10
    t.decimal  "iznos_pdv",                           precision: 10
    t.decimal  "ukupan_iznos_racuna_pdv",             precision: 10
    t.decimal  "placeni_iznos_racuna",                precision: 10
    t.decimal  "neplaceni_dio_racuna",                precision: 10
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.integer  "kupac_id",                limit: 4
  end

  create_table "zaglavljes", force: :cascade do |t|
    t.date     "datum_od"
    t.date     "datum_do"
    t.integer  "oib",               limit: 4
    t.string   "naziv",             limit: 255
    t.string   "mjesto",            limit: 255
    t.string   "ulica",             limit: 255
    t.string   "broj",              limit: 255
    t.string   "email",             limit: 255
    t.string   "sastavio_ime",      limit: 255
    t.string   "sastavio_prezime",  limit: 255
    t.string   "sastavio_tel",      limit: 255
    t.string   "sastavio_fax",      limit: 255
    t.string   "sastavio_email",    limit: 255
    t.date     "na_dan"
    t.date     "nisu_naplaceni_do"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

end
