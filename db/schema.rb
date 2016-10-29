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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20161011015735) do

  create_table "admin_users", :force => true do |t|
    t.string   "first_name",       :default => "",    :null => false
    t.string   "last_name",        :default => "",    :null => false
    t.string   "role",                                :null => false
    t.string   "email",                               :null => false
    t.boolean  "status",           :default => false
    t.string   "token",                               :null => false
    t.string   "salt",                                :null => false
    t.string   "crypted_password",                    :null => false
    t.string   "preferences"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  add_index "admin_users", ["email"], :name => "index_admin_users_on_email", :unique => true

  create_table "adverts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "type_id"
    t.integer  "uid"
    t.string   "make_model"
    t.decimal  "price",            :precision => 8, :scale => 2
    t.string   "contact_number"
    t.string   "secondary_number"
    t.string   "email"
    t.boolean  "basics_saved",                                   :default => false, :null => false
    t.boolean  "details_saved",                                  :default => false, :null => false
    t.boolean  "features_saved",                                 :default => false, :null => false
    t.boolean  "photos_saved",                                   :default => false, :null => false
    t.boolean  "contact_saved",                                  :default => false, :null => false
    t.boolean  "activated",                                      :default => false, :null => false
    t.boolean  "sold",                                           :default => false, :null => false
    t.string   "ad_type"
    t.string   "status"
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
    t.datetime "deleted_at"
    t.integer  "delete_reason_id"
    t.datetime "activated_at"
  end

  add_index "adverts", ["deleted_at"], :name => "index_adverts_on_deleted_at"

  create_table "authentications", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "bodytype_translations", :force => true do |t|
    t.integer "bodytype_id"
    t.string  "locale",      :null => false
    t.string  "name"
  end

  add_index "bodytype_translations", ["bodytype_id"], :name => "index_bodytype_translations_on_bodytype_id"
  add_index "bodytype_translations", ["locale"], :name => "index_bodytype_translations_on_locale", :length => {"locale"=>191}

  create_table "bodytypes", :force => true do |t|
    t.integer "type_id"
    t.string  "name"
    t.integer "popularity", :default => 0, :null => false
  end

  create_table "cities", :force => true do |t|
    t.string  "name"
    t.integer "state_id"
  end

  create_table "comments", :force => true do |t|
    t.text     "text"
    t.integer  "vehicle_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "ancestry"
    t.datetime "deleted_at"
  end

  add_index "comments", ["ancestry"], :name => "index_comments_on_ancestry"
  add_index "comments", ["deleted_at"], :name => "index_comments_on_deleted_at"

  create_table "compared_items", :force => true do |t|
    t.integer  "vehicle_id"
    t.integer  "user_id"
    t.string   "ip_address"
    t.string   "session_hash"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "compared_items", ["vehicle_id"], :name => "index_compared_items_on_vehicle_id"

  create_table "countries", :force => true do |t|
    t.string "name"
  end

  create_table "country_translations", :force => true do |t|
    t.integer  "country_id"
    t.string   "locale",     :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "name"
  end

  add_index "country_translations", ["country_id"], :name => "index_country_translations_on_country_id"
  add_index "country_translations", ["locale"], :name => "index_country_translations_on_locale", :length => {"locale"=>191}

  create_table "dealer_pictures", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "file"
    t.string   "remote_file_url"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "garage_items", :force => true do |t|
    t.integer  "vehicle_id",   :null => false
    t.integer  "advert_id"
    t.integer  "user_id"
    t.integer  "ownership_id", :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "garage_items", ["vehicle_id", "user_id"], :name => "index_saved_items_on_vehicle_id_and_user_id"

  create_table "impressions", :force => true do |t|
    t.integer  "vehicle_id"
    t.integer  "user_id"
    t.string   "controller_name"
    t.string   "action_name"
    t.string   "request_hash"
    t.string   "ip_address"
    t.string   "session_hash"
    t.text     "referrer"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "impressions", ["user_id"], :name => "index_impressions_on_user_id"
  add_index "impressions", ["vehicle_id", "ip_address"], :name => "poly_ip_index"
  add_index "impressions", ["vehicle_id", "request_hash"], :name => "poly_request_index"
  add_index "impressions", ["vehicle_id", "session_hash"], :name => "poly_session_index"

  create_table "line_items", :force => true do |t|
    t.integer  "service_id"
    t.integer  "order_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "make_model_fields", :force => true do |t|
    t.integer "search_id"
    t.string  "make_name"
    t.string  "model_name"
  end

  create_table "makes", :force => true do |t|
    t.integer "type_id"
    t.string  "name"
    t.integer "popularity", :default => 0, :null => false
  end

  create_table "models", :force => true do |t|
    t.integer "make_id"
    t.integer "type_id"
    t.string  "name"
    t.integer "serie_id"
    t.integer "popularity", :default => 0, :null => false
  end

  create_table "orders", :force => true do |t|
    t.integer  "advert_id"
    t.string   "pay_type"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "orders", ["advert_id"], :name => "index_orders_on_advert_id"

  create_table "photos", :force => true do |t|
    t.integer  "vehicle_id"
    t.string   "name"
    t.integer  "position"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.boolean  "image_processing",   :default => false, :null => false
  end

  create_table "pictures", :force => true do |t|
    t.integer  "vehicle_id"
    t.string   "name"
    t.string   "file"
    t.string   "remote_file_url"
    t.integer  "position"
    t.datetime "created_at",      :null => false
    t.datetime "deleted_at"
  end

  add_index "pictures", ["deleted_at"], :name => "index_pictures_on_deleted_at"

  create_table "price_alerts", :force => true do |t|
    t.integer  "vehicle_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "price_alerts", ["vehicle_id"], :name => "index_price_alerts_on_vehicle_id"

  create_table "price_changes", :force => true do |t|
    t.integer  "vehicle_id"
    t.decimal  "value",      :precision => 8, :scale => 2
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.datetime "deleted_at"
  end

  add_index "price_changes", ["deleted_at"], :name => "index_price_changes_on_deleted_at"
  add_index "price_changes", ["vehicle_id"], :name => "index_price_changes_on_vehicle_id"

  create_table "review_translations", :force => true do |t|
    t.integer  "review_id"
    t.string   "locale",     :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.text     "experience"
  end

  add_index "review_translations", ["locale"], :name => "index_review_translations_on_locale"
  add_index "review_translations", ["review_id"], :name => "index_review_translations_on_review_id"

  create_table "reviews", :force => true do |t|
    t.integer  "vehicle_id"
    t.integer  "bodytype_id"
    t.integer  "make_id"
    t.integer  "model_id"
    t.string   "model_spec"
    t.integer  "transmission_id"
    t.integer  "year"
    t.string   "badge"
    t.string   "series"
    t.integer  "odometer"
    t.integer  "how_well"
    t.boolean  "first_owner"
    t.integer  "how_long",                                                         :null => false
    t.integer  "performance",                                                      :null => false
    t.integer  "practicality",                                                     :null => false
    t.integer  "reliability",                                                      :null => false
    t.integer  "running_costs",                                                    :null => false
    t.decimal  "overall",         :precision => 2, :scale => 1
    t.text     "title"
    t.text     "experience"
    t.boolean  "a_to_b",                                        :default => false
    t.boolean  "outdoors",                                      :default => false
    t.boolean  "offroading",                                    :default => false
    t.boolean  "extra_car",                                     :default => false
    t.boolean  "family_car",                                    :default => false
    t.boolean  "towing",                                        :default => false
    t.boolean  "first_car",                                     :default => false
    t.boolean  "weekend",                                       :default => false
    t.boolean  "holiday",                                       :default => false
    t.boolean  "job",                                           :default => false
    t.boolean  "racing",                                        :default => false
    t.boolean  "showing",                                       :default => false
    t.integer  "like1"
    t.integer  "like2"
    t.integer  "like3"
    t.integer  "dislike1"
    t.integer  "dislike2"
    t.integer  "dislike3"
    t.boolean  "recommend",                                     :default => false
    t.string   "first_name"
    t.integer  "user_id",                                                          :null => false
    t.datetime "created_at",                                                       :null => false
    t.datetime "updated_at",                                                       :null => false
    t.string   "how_well_other"
  end

  create_table "saved_items", :force => true do |t|
    t.integer  "vehicle_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "type_id"
  end

  add_index "saved_items", ["vehicle_id", "user_id"], :name => "index_saved_items_on_vehicle_id_and_user_id"

  create_table "search_alerts", :force => true do |t|
    t.integer  "search_id"
    t.integer  "user_id"
    t.text     "results",    :limit => 2147483647
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "search_alerts", ["search_id"], :name => "index_search_alerts_on_search_id"
  add_index "search_alerts", ["user_id"], :name => "index_search_alerts_on_user_id"

  create_table "searches", :force => true do |t|
    t.string   "keywords"
    t.integer  "tp"
    t.string   "bt"
    t.integer  "fpgt"
    t.integer  "fplt"
    t.integer  "pwgt"
    t.integer  "pwlt"
    t.integer  "kmgt"
    t.integer  "kmlt"
    t.date     "yeargt"
    t.date     "yearlt"
    t.string   "ft"
    t.string   "tm"
    t.string   "dt"
    t.string   "cl"
    t.string   "slug"
    t.datetime "created_at",                                                                               :null => false
    t.datetime "updated_at",                                                                               :null => false
    t.datetime "saved_at"
    t.string   "user_ip"
    t.integer  "user_id"
    t.string   "name"
    t.string   "location"
    t.string   "region"
    t.string   "doors"
    t.integer  "stgt"
    t.integer  "stlt"
    t.decimal  "engine_size",                        :precision => 2, :scale => 1
    t.boolean  "is_dealer",                                                        :default => true
    t.boolean  "is_private",                                                       :default => true
    t.boolean  "wrecked",                                                          :default => false
    t.boolean  "exchange",                                                         :default => false
    t.string   "features"
    t.string   "dealers"
    t.string   "sort"
    t.integer  "exception"
    t.boolean  "allow_alerts",                                                     :default => false
    t.text     "results",      :limit => 2147483647
    t.integer  "total",                                                            :default => 0,          :null => false
    t.string   "alert_freq",                                                       :default => "No Alert"
  end

  add_index "searches", ["slug"], :name => "index_searches_on_slug", :unique => true

  create_table "series", :force => true do |t|
    t.string  "name"
    t.integer "make_id"
  end

  create_table "services", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.decimal  "price",       :precision => 8, :scale => 2
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "states", :force => true do |t|
    t.string  "name"
    t.integer "country_id"
  end

  create_table "types", :force => true do |t|
    t.string "name"
    t.string "path_name"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "city_str"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "name"
    t.string   "company_name"
    t.string   "company_reg"
    t.string   "company_kmkr"
    t.string   "address1"
    t.string   "address2"
    t.integer  "city_id"
    t.integer  "country_id"
    t.integer  "state_id"
    t.string   "postal_code"
    t.string   "phone1"
    t.string   "phone2"
    t.string   "webpage"
    t.text     "information"
    t.boolean  "is_dealer",              :default => false
    t.boolean  "price_alert",            :default => false
    t.boolean  "sold_alert",             :default => false
    t.boolean  "interest_alert",         :default => false
    t.boolean  "auto_alerts",            :default => false
    t.boolean  "feature_alerts",         :default => false
    t.string   "locale",                 :default => "et",  :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "vehicle_translations", :force => true do |t|
    t.integer  "vehicle_id"
    t.string   "locale",      :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.text     "description"
    t.datetime "deleted_at"
  end

  add_index "vehicle_translations", ["locale"], :name => "index_vehicle_translations_on_locale", :length => {"locale"=>191}
  add_index "vehicle_translations", ["vehicle_id"], :name => "index_vehicle_translations_on_vehicle_id"

  create_table "vehicle_watchers", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "vehicle_id"
  end

  create_table "vehicles", :force => true do |t|
    t.integer  "advert_id"
    t.integer  "type_id"
    t.integer  "make_id"
    t.integer  "model_id"
    t.string   "model_spec"
    t.string   "make_model"
    t.string   "badge"
    t.string   "series"
    t.string   "vin"
    t.integer  "year"
    t.decimal  "price",                                                 :precision => 8, :scale => 2
    t.boolean  "price_vat",                                                                           :default => false
    t.boolean  "price_negotiable",                                                                    :default => false
    t.string   "warranty_valid_to"
    t.integer  "warranty_km"
    t.integer  "service_freq"
    t.integer  "service_km"
    t.string   "next_service"
    t.integer  "next_service_km"
    t.boolean  "service_book",                                                                        :default => false
    t.integer  "owners"
    t.string   "registered_at"
    t.string   "inspection_valid_to"
    t.boolean  "registered",                                                                          :default => false
    t.boolean  "show_reg_nr",                                                                         :default => true,  :null => false
    t.integer  "origin_id"
    t.boolean  "wrecked",                                                                             :default => false
    t.boolean  "exchange",                                                                            :default => false
    t.string   "wrecked_details"
    t.string   "exchange_details"
    t.integer  "climate_control_id"
    t.integer  "net_weight"
    t.integer  "gross_weight"
    t.integer  "load_capacity"
    t.integer  "length"
    t.integer  "width"
    t.integer  "height"
    t.integer  "wheelbase"
    t.text     "other_info"
    t.integer  "colour_id"
    t.string   "specific_colour"
    t.boolean  "metallic_colour",                                                                     :default => false
    t.integer  "seats",                                                                               :default => 0,     :null => false
    t.integer  "doors",                                                                               :default => 0,     :null => false
    t.integer  "bodytype_id"
    t.string   "bodytype_details"
    t.integer  "odometer"
    t.integer  "drivetype_id"
    t.decimal  "engine_size",                                           :precision => 2, :scale => 1
    t.string   "engine_type"
    t.integer  "engine_power"
    t.integer  "fueltype_id"
    t.integer  "service_history_id"
    t.integer  "fueltank"
    t.integer  "emissions"
    t.integer  "transmission_id"
    t.string   "transmission_details"
    t.integer  "gears",                                                                               :default => 0,     :null => false
    t.integer  "cylinders",                                                                           :default => 0,     :null => false
    t.decimal  "fuel_cons_city",                                        :precision => 3, :scale => 1
    t.decimal  "fuel_cons_freeway",                                     :precision => 3, :scale => 1
    t.decimal  "fuel_cons_combined",                                    :precision => 3, :scale => 1
    t.decimal  "acceleration",                                          :precision => 3, :scale => 1
    t.integer  "max_speed"
    t.boolean  "power_steering",                                                                      :default => false
    t.string   "power_steering_details"
    t.boolean  "central_locking",                                                                     :default => false
    t.boolean  "with_remote",                                                                         :default => false
    t.boolean  "abs",                                                                                 :default => false
    t.integer  "airbags",                                                                             :default => 0
    t.boolean  "alarm",                                                                               :default => false
    t.string   "alarm_details"
    t.boolean  "alarm_with_tow_away_protection",                                                      :default => false
    t.boolean  "alarm_with_motion_sensor",                                                            :default => false
    t.boolean  "alarm_with_two_way_comm",                                                             :default => false
    t.boolean  "immobilizer",                                                                         :default => false
    t.boolean  "anti_skidding",                                                                       :default => false
    t.string   "anti_skidding_details"
    t.boolean  "stability_control",                                                                   :default => false
    t.string   "stability_control_details"
    t.boolean  "braking_force_reg",                                                                   :default => false
    t.string   "braking_force_reg_details"
    t.boolean  "traction_control",                                                                    :default => false
    t.string   "traction_control_details"
    t.boolean  "third_brake_light",                                                                   :default => false
    t.boolean  "rain_sensor",                                                                         :default => false
    t.boolean  "seatbelt_pretightener",                                                               :default => false
    t.boolean  "xenon",                                                                               :default => false
    t.boolean  "xenon_high_beam",                                                                     :default => false
    t.boolean  "xenon_low_beam",                                                                      :default => false
    t.boolean  "headlight_washer",                                                                    :default => false
    t.boolean  "special_light",                                                                       :default => false
    t.boolean  "fog_lights",                                                                          :default => false
    t.boolean  "fog_lights_front",                                                                    :default => false
    t.boolean  "fog_lights_rear",                                                                     :default => false
    t.boolean  "headlight_range",                                                                     :default => false
    t.boolean  "extra_lights",                                                                        :default => false
    t.string   "extra_lights_details"
    t.boolean  "auto_light",                                                                          :default => false
    t.boolean  "summer_tires",                                                                        :default => false
    t.string   "summer_tires_details"
    t.string   "summer_tires_size"
    t.boolean  "winter_tires",                                                                        :default => false
    t.string   "winter_tires_details"
    t.string   "winter_tires_size"
    t.boolean  "all_season_tires",                                                                    :default => false
    t.boolean  "spike_tires",                                                                         :default => false
    t.boolean  "light_alloy_wheels",                                                                  :default => false
    t.string   "light_alloy_wheels_size"
    t.boolean  "dust_shields",                                                                        :default => false
    t.boolean  "steering_wheel_adjustment",                                                           :default => false
    t.boolean  "steering_wheel_height_and_depth",                                                     :default => false
    t.boolean  "steering_wheel_electrical",                                                           :default => false
    t.boolean  "steering_wheel_with_memory",                                                          :default => false
    t.boolean  "steering_wheel_multifunctional",                                                      :default => false
    t.boolean  "steering_wheel_leather",                                                              :default => false
    t.boolean  "car_stereo",                                                                          :default => false
    t.string   "car_stereo_details"
    t.boolean  "car_stereo_cd",                                                                       :default => false
    t.boolean  "car_stereo_mp3",                                                                      :default => false
    t.boolean  "car_stereo_aux",                                                                      :default => false
    t.boolean  "car_stereo_usb",                                                                      :default => false
    t.boolean  "car_stereo_card",                                                                     :default => false
    t.boolean  "car_stereo_original",                                                                 :default => false
    t.boolean  "car_stereo_with_remote",                                                              :default => false
    t.integer  "speakers_count",                                                                      :default => 0,     :null => false
    t.boolean  "subwoofer",                                                                           :default => false
    t.boolean  "cd_changer",                                                                          :default => false
    t.boolean  "electric_antenna",                                                                    :default => false
    t.boolean  "navigation",                                                                          :default => false
    t.boolean  "computer",                                                                            :default => false
    t.boolean  "car_phone",                                                                           :default => false
    t.boolean  "hands_free",                                                                          :default => false
    t.string   "hands_free_details"
    t.boolean  "gsm",                                                                                 :default => false
    t.boolean  "trim",                                                                                :default => false
    t.boolean  "cloth_upholstery",                                                                    :default => false
    t.boolean  "vinyl_upholstery",                                                                    :default => false
    t.boolean  "faux_leather_upholstery",                                                             :default => false
    t.boolean  "leather_upholstery",                                                                  :default => false
    t.boolean  "wood_grain",                                                                          :default => false
    t.boolean  "chrome",                                                                              :default => false
    t.boolean  "mats",                                                                                :default => false
    t.boolean  "textile_mats",                                                                        :default => false
    t.boolean  "rubber_mats",                                                                         :default => false
    t.boolean  "velour_mats",                                                                         :default => false
    t.boolean  "leather_shift_lever",                                                                 :default => false
    t.boolean  "leather_hand_break",                                                                  :default => false
    t.integer  "seat_heating_count",                                                                  :default => 0,     :null => false
    t.boolean  "front_armrest",                                                                       :default => false
    t.boolean  "rear_armrest",                                                                        :default => false
    t.boolean  "down_folding_back_rest",                                                              :default => false
    t.boolean  "electric_mirrors",                                                                    :default => false
    t.boolean  "heated_mirrors",                                                                      :default => false
    t.boolean  "folding_mirrors",                                                                     :default => false
    t.boolean  "mirrors_with_memory",                                                                 :default => false
    t.boolean  "tinted_windows",                                                                      :default => false
    t.boolean  "power_windows",                                                                       :default => false
    t.boolean  "rear_wiper",                                                                          :default => false
    t.boolean  "sunroof",                                                                             :default => false
    t.string   "sunroof_details"
    t.boolean  "cruise_control",                                                                      :default => false
    t.boolean  "distance_monitoring",                                                                 :default => false
    t.boolean  "engine_preheating",                                                                   :default => false
    t.string   "engine_preheating_details"
    t.boolean  "spot_lights",                                                                         :default => false
    t.boolean  "parking_aid",                                                                         :default => false
    t.boolean  "inside_temperature_indicator",                                                        :default => false
    t.boolean  "sump_shield",                                                                         :default => false
    t.boolean  "side_steps",                                                                          :default => false
    t.boolean  "roof_railings",                                                                       :default => false
    t.boolean  "roof_rack",                                                                           :default => false
    t.boolean  "outside_temperature_indicator",                                                       :default => false
    t.boolean  "front_window_heating",                                                                :default => false
    t.boolean  "rear_window_heating",                                                                 :default => false
    t.boolean  "luggage_cover",                                                                       :default => false
    t.boolean  "isolation_net",                                                                       :default => false
    t.boolean  "tow_hitch",                                                                           :default => false
    t.text     "other_equipment"
    t.boolean  "parking_aid_front",                                                                   :default => false
    t.boolean  "parking_aid_rear",                                                                    :default => false
    t.boolean  "electrical_seats_with_memory",                                                        :default => false
    t.integer  "electrical_seats_count",                                                              :default => 0,     :null => false
    t.string   "light_alloy_wheels_details"
    t.boolean  "tow_hitch_removable",                                                                 :default => false
    t.boolean  "tow_hitch_electrical",                                                                :default => false
    t.integer  "country_id"
    t.integer  "state_id"
    t.integer  "city_id"
    t.integer  "user_id"
    t.text     "description"
    t.string   "reg_nr"
    t.integer  "popularity",                                                                          :default => 0
    t.text     "keywords",                        :limit => 2147483647
    t.datetime "updated_at",                                                                                             :null => false
    t.datetime "created_at",                                                                                             :null => false
    t.datetime "deleted_at"
    t.datetime "ad_activated_at"
  end

  add_index "vehicles", ["deleted_at"], :name => "index_vehicles_on_deleted_at"
  add_index "vehicles", ["user_id"], :name => "index_vehicles_on_user_id"

end
