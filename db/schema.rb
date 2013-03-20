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

ActiveRecord::Schema.define(:version => 20130308080403) do

  create_table "abtests", :force => true do |t|
    t.string  "slug"
    t.integer "inc",    :default => 0, :null => false
    t.integer "maxinc", :default => 1, :null => false
  end

  create_table "active_admin_comments", :force => true do |t|
    t.string   "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "activities", :force => true do |t|
    t.integer  "user_id"
    t.integer  "creator_id"
    t.integer  "activityType"
    t.integer  "message_id"
    t.integer  "interview_id"
    t.integer  "application_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "blog_url"
    t.string   "blog_title"
  end

  create_table "alphas", :force => true do |t|
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "userType"
    t.string   "name"
    t.boolean  "beta"
  end

  create_table "analytics", :force => true do |t|
    t.string   "slug"
    t.text     "message"
    t.string   "path"
    t.integer  "user_id"
    t.string   "tag"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "session_id"
    t.string   "group"
  end

  create_table "applications", :force => true do |t|
    t.integer  "job_id",                          :null => false
    t.text     "additional_notes"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "viewed"
    t.integer  "video_id"
    t.integer  "submitted",        :default => 0
    t.integer  "user_id"
  end

  add_index "applications", ["job_id"], :name => "index_applications_on_job_id"

  create_table "assets", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.integer  "application_id"
    t.integer  "assetType",         :default => 0
    t.integer  "job_id"
    t.integer  "user_id"
    t.string   "owner_type"
    t.integer  "owner_id"
    t.string   "original_filename"
  end

  create_table "attachments", :force => true do |t|
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.integer  "video_id"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "authentications", :force => true do |t|
    t.string   "provider"
    t.integer  "user_id"
    t.string   "uid"
    t.string   "token"
    t.string   "secret"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "awards", :force => true do |t|
    t.string   "title"
    t.string   "issuer"
    t.datetime "date"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "banners", :force => true do |t|
    t.string   "message"
    t.datetime "start"
    t.datetime "stop"
    t.integer  "recurring"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "blog_entries", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.text     "content"
  end

  create_table "comments", :force => true do |t|
    t.integer  "commentable_id",   :default => 0
    t.string   "commentable_type", :default => ""
    t.string   "title",            :default => ""
    t.text     "body"
    t.string   "subject",          :default => ""
    t.integer  "user_id",          :default => 0,  :null => false
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "connection_invites", :force => true do |t|
    t.string   "email"
    t.integer  "user_id"
    t.boolean  "pending",         :default => true
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_user_id"
    t.boolean  "donors_choose",   :default => true
  end

  create_table "connections", :force => true do |t|
    t.integer  "owned_by"
    t.integer  "user_id"
    t.boolean  "pending",    :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "credentials", :force => true do |t|
    t.string   "credentialType", :null => false
    t.string   "name",           :null => false
    t.string   "issuer"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
  end

  create_table "credentials_jobs", :id => false, :force => true do |t|
    t.integer "job_id",        :null => false
    t.integer "credential_id", :null => false
  end

  add_index "credentials_jobs", ["credential_id", "job_id"], :name => "index_credentials_jobs_on_credential_id_and_job_id"
  add_index "credentials_jobs", ["job_id"], :name => "index_credentials_jobs_on_job_id"

  create_table "credentials_users", :id => false, :force => true do |t|
    t.integer "credential_id", :null => false
    t.integer "user_id"
  end

  add_index "credentials_users", ["credential_id"], :name => "index_credentials_teachers_on_credential_id_and_teacher_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "discussion_tags", :force => true do |t|
    t.integer  "skill_id"
    t.integer  "discussion_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "discussion_tags", ["discussion_id"], :name => "index_discussion_tags_on_discussion_id"
  add_index "discussion_tags", ["skill_id"], :name => "index_discussion_tags_on_skill_id"

  create_table "discussions", :force => true do |t|
    t.string   "title"
    t.text     "message"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "owner"
  end

  add_index "discussions", ["owner"], :name => "index_discussions_on_owner"
  add_index "discussions", ["user_id"], :name => "index_discussions_on_user_id"

  create_table "edu_stats", :force => true do |t|
    t.integer  "user_id"
    t.integer  "yrs_teaching"
    t.integer  "avg_class_size"
    t.integer  "class_perday"
    t.integer  "total_students"
    t.integer  "total_hours_teaching"
    t.integer  "total_hours_planning"
    t.integer  "total_hours_grading"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "edu_network_public"
    t.integer  "edu_network_private"
    t.integer  "edu_network_charter"
    t.integer  "edu_network_catholic"
  end

  create_table "educations", :force => true do |t|
    t.string   "school"
    t.string   "degree"
    t.string   "concentrations"
    t.integer  "year"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "start_year"
    t.boolean  "current"
    t.integer  "user_id"
  end

  create_table "eventformats", :force => true do |t|
    t.string  "name",    :null => false
    t.boolean "virtual"
  end

  create_table "events", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "loc_name"
    t.string   "loc_address"
    t.string   "loc_address1"
    t.string   "loc_city"
    t.string   "loc_state"
    t.string   "loc_zip"
    t.float    "loc_latitude"
    t.float    "loc_longitude"
    t.boolean  "virtual"
    t.string   "virtual_phone"
    t.string   "virtual_phone_access"
    t.string   "virtual_web_link"
    t.string   "virtual_web_access"
    t.string   "virtual_tv_station"
    t.string   "host_organization"
    t.string   "host_organization_website"
    t.boolean  "public_event"
    t.boolean  "rsvp_req"
    t.datetime "rsvp_deadline"
    t.float    "attendance_cost"
    t.boolean  "published",                 :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "rsvp_external"
    t.boolean  "email_sent"
  end

  create_table "events_eventformats", :id => false, :force => true do |t|
    t.integer "event_id"
    t.integer "eventformat_id"
  end

  create_table "events_eventtopics", :id => false, :force => true do |t|
    t.integer "event_id"
    t.integer "eventtopic_id"
  end

  create_table "events_rsvps", :id => false, :force => true do |t|
    t.integer  "event_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events_skills", :id => false, :force => true do |t|
    t.integer  "event_id"
    t.integer  "skill_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "eventtopics", :force => true do |t|
    t.string "name", :null => false
  end

  create_table "experiences", :force => true do |t|
    t.string   "company"
    t.string   "position"
    t.string   "description", :limit => 10000
    t.integer  "startMonth"
    t.integer  "startYear"
    t.integer  "endMonth"
    t.integer  "endYear"
    t.boolean  "current"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "favorites", :force => true do |t|
    t.integer  "user_id"
    t.string   "model"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "followers", :force => true do |t|
    t.integer  "user_id"
    t.integer  "discussion_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "followers", ["discussion_id"], :name => "index_followers_on_discussion_id"
  add_index "followers", ["user_id"], :name => "index_followers_on_user_id"

  create_table "grades", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "grades", ["name"], :name => "index_grades_on_name"

  create_table "grades_jobs", :force => true do |t|
    t.integer  "job_id"
    t.integer  "grade_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "grades_users", :force => true do |t|
    t.integer  "grade_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "groups", :force => true do |t|
    t.string   "name",                                    :null => false
    t.text     "description",                             :null => false
    t.integer  "permissions",          :default => 0,     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "picture_file_name"
    t.string   "picture_content_type"
    t.integer  "picture_file_size"
    t.datetime "picture_updated_at"
    t.string   "site"
    t.string   "twitter"
    t.string   "facebook"
    t.text     "long_description"
    t.float    "latitude"
    t.float    "longitude"
    t.boolean  "featured",             :default => false
  end

  create_table "helpful_queries", :force => true do |t|
    t.string "query"
  end

  create_table "interviews", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "job_id"
    t.datetime "datetime_1"
    t.datetime "datetime_2"
    t.datetime "datetime_3"
    t.integer  "datetime_selected", :default => 0
    t.string   "location"
    t.text     "message"
    t.integer  "user_id"
    t.integer  "number"
    t.integer  "application_id"
    t.string   "interview_type"
    t.integer  "round",             :default => 1
  end

  create_table "job_answers", :force => true do |t|
    t.integer  "question_id"
    t.integer  "application_id"
    t.text     "answer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "job_packs", :force => true do |t|
    t.integer  "group_id"
    t.integer  "jobs"
    t.datetime "expiration"
    t.datetime "inception"
    t.string   "charge_token"
    t.string   "card_token"
    t.integer  "refunded"
    t.integer  "amount"
    t.text     "additional_data"
  end

  create_table "job_questions", :force => true do |t|
    t.integer  "job_id"
    t.text     "question"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "jobs", :force => true do |t|
    t.integer  "school_id"
    t.text     "description"
    t.integer  "employment_type"
    t.string   "salary"
    t.boolean  "special_needs"
    t.datetime "deadline"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.integer  "multiple_subject"
    t.integer  "bilingual"
    t.integer  "experience_years"
    t.integer  "education_level"
    t.datetime "start_date"
    t.boolean  "active",              :default => true
    t.integer  "grade_level"
    t.integer  "credential_type"
    t.integer  "years_of_experience"
    t.boolean  "rolling_deadline",    :default => false
    t.string   "passcode"
    t.float    "latitude"
    t.float    "longitude"
    t.boolean  "immediate",           :default => false
    t.text     "instructions"
    t.string   "external_url"
    t.integer  "group_id"
    t.string   "status"
    t.boolean  "featured",            :default => false
    t.boolean  "allow_videos",        :default => true
    t.boolean  "allow_attachments",   :default => true
    t.boolean  "notification_sent",   :default => false
  end

  add_index "jobs", ["school_id"], :name => "index_jobs_on_school_id"

  create_table "jobs_subjects", :id => false, :force => true do |t|
    t.integer  "job_id",     :null => false
    t.integer  "subject_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "jobs_subjects", ["job_id"], :name => "index_jobs_subjects_on_job_id"
  add_index "jobs_subjects", ["subject_id", "job_id"], :name => "index_jobs_subjects_on_subject_id_and_job_id"

  create_table "kvpairs", :force => true do |t|
    t.string "owner"
    t.string "namespace"
    t.string "key"
    t.text   "value"
  end

  add_index "kvpairs", ["key"], :name => "index_kvpairs_on_key"
  add_index "kvpairs", ["namespace"], :name => "index_kvpairs_on_namespace"
  add_index "kvpairs", ["owner"], :name => "index_kvpairs_on_owner"

  create_table "login_tokens", :force => true do |t|
    t.integer  "user_id"
    t.datetime "expires_at"
    t.string   "token_value", :limit => 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "login_tokens", ["user_id"], :name => "index_login_tokens_on_user_id", :unique => true

  create_table "messages", :force => true do |t|
    t.integer  "user_id_from"
    t.integer  "user_id_to"
    t.string   "subject"
    t.string   "body",          :limit => 10000
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "read"
    t.string   "tag"
    t.integer  "replied_to_id"
    t.datetime "replied_at"
  end

  add_index "messages", ["replied_to_id"], :name => "index_messages_on_replied_to_id"
  add_index "messages", ["user_id_from"], :name => "index_messages_on_user_id_from"
  add_index "messages", ["user_id_to"], :name => "index_messages_on_user_id_to"

  create_table "notifications", :force => true do |t|
    t.string   "notifiable_type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "dashboard"
    t.string   "message"
    t.string   "link"
    t.text     "data"
    t.integer  "triggered_id"
    t.boolean  "emailed",         :default => false
    t.datetime "emailed_at"
    t.string   "bucket"
    t.string   "link_text"
  end

  create_table "organizations", :force => true do |t|
    t.integer  "owned_by"
    t.string   "name"
    t.integer  "job_allowance",    :default => 1
    t.integer  "admin_allowance",  :default => 1
    t.integer  "school_allowance", :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "totaljobs",        :default => 0
    t.integer  "totaladmins",      :default => 1
    t.integer  "totalschools",     :default => 1
  end

  create_table "passcodes", :force => true do |t|
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "given_out"
    t.string   "sent_to"
  end

  create_table "presentations", :force => true do |t|
    t.string   "title"
    t.string   "url"
    t.string   "location"
    t.datetime "date"
    t.string   "author"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "pricing_models", :force => true do |t|
    t.string   "region"
    t.string   "country"
    t.string   "cycle_length"
    t.decimal  "price_per_cycle", :precision => 30, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "returned_skills", :force => true do |t|
    t.integer  "vouch_id"
    t.integer  "skill_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "review_permissions", :id => false, :force => true do |t|
    t.integer "user_id", :null => false
    t.integer "job_id",  :null => false
  end

  add_index "review_permissions", ["job_id"], :name => "index_review_permissions_on_job_id"
  add_index "review_permissions", ["user_id"], :name => "index_review_permissions_on_user_id"

  create_table "reviews", :force => true do |t|
    t.integer  "application_id", :null => false
    t.integer  "reviewer_id",    :null => false
    t.string   "rating"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reviews", ["application_id"], :name => "index_reviews_on_application_id"
  add_index "reviews", ["reviewer_id"], :name => "index_reviews_on_reviewer_id"

  create_table "school_administrators", :force => true do |t|
    t.integer  "user_id"
    t.integer  "school_id"
    t.integer  "owner_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "schools", :force => true do |t|
    t.string   "name"
    t.string   "location"
    t.text     "description"
    t.integer  "owned_by",                                               :null => false
    t.float    "longitude"
    t.float    "latitude"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "district"
    t.string   "representative_title"
    t.string   "map_address"
    t.string   "map_city"
    t.integer  "map_state"
    t.integer  "map_zip"
    t.string   "phone"
    t.string   "fax"
    t.integer  "school_type"
    t.integer  "grades"
    t.string   "students_count",       :limit => 25
    t.string   "api_ayp_scores"
    t.integer  "calendar"
    t.string   "mission",              :limit => 1000
    t.boolean  "gmaps"
    t.string   "website"
    t.string   "greatschools"
    t.string   "linkedin"
    t.string   "facebook"
    t.boolean  "show_personal_info",                   :default => true
    t.string   "picture_file_name"
    t.string   "picture_content_type"
    t.integer  "picture_file_size"
    t.datetime "picture_updated_at"
    t.string   "additionallinkname"
    t.string   "additionallink"
    t.string   "twitter"
    t.integer  "migrated"
  end

  add_index "schools", ["latitude", "longitude"], :name => "index_schools_on_lat_and_lng"
  add_index "schools", ["owned_by"], :name => "index_schools_on_owned_by"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "remember"
    t.integer  "user_id"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "shared_schools", :force => true do |t|
    t.integer  "owned_by"
    t.integer  "school_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shared_users", :force => true do |t|
    t.integer  "owned_by"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "skill_claims", :force => true do |t|
    t.integer  "user_id"
    t.integer  "skill_id"
    t.integer  "skill_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "skill_group_descriptions", :force => true do |t|
    t.string   "description"
    t.integer  "user_id"
    t.integer  "skill_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "skill_groups", :force => true do |t|
    t.string   "badge_url"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "placeholder"
  end

  create_table "skills", :force => true do |t|
    t.integer  "skill_group_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "skills_to_vouch", :force => true do |t|
    t.integer  "skill_id"
    t.integer  "vouch_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subjects", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subjects_users", :id => false, :force => true do |t|
    t.integer  "subject_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "subjects_users", ["subject_id"], :name => "index_subjects_teachers_on_subject_id_and_teacher_id"

  create_table "teacher_links", :force => true do |t|
    t.integer  "teacher_id"
    t.string   "url"
    t.integer  "type"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "technologies", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "site"
    t.string   "twitter"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "picture_file_name"
    t.string   "picture_content_type"
    t.integer  "picture_file_size"
    t.datetime "picture_updated_at"
    t.string   "facebook"
  end

  create_table "technology_suggestions", :force => true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "technology_tags", :force => true do |t|
    t.integer  "technology_id"
    t.integer  "skill_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "technology_users", :force => true do |t|
    t.integer  "user_id"
    t.integer  "technology_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_delayed_jobs", :force => true do |t|
    t.integer  "delayed_job_id"
    t.integer  "user_id"
    t.integer  "vouchee_id"
    t.datetime "action_start"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.boolean  "fake",                   :default => false
    t.string   "email",                                     :null => false
    t.string   "hashed_password",                           :null => false
    t.string   "salt",                                      :null => false
    t.string   "name"
    t.boolean  "is_admin",               :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.integer  "login_count",            :default => 0
    t.datetime "last_login"
    t.datetime "deleted_at"
    t.boolean  "is_shared",              :default => false, :null => false
    t.boolean  "is_limited",             :default => false, :null => false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "original_name"
    t.string   "temp_img_name"
    t.integer  "privacy_public",         :default => 0,     :null => false
    t.string   "invite_code"
    t.string   "ab"
    t.integer  "completion"
    t.integer  "email_permissions",      :default => 0
    t.string   "twitter_oauth_token"
    t.string   "twitter_oauth_secret"
    t.string   "facebook_access_token"
    t.string   "slug"
    t.string   "guest_code"
    t.string   "location"
    t.string   "dashboard"
    t.string   "headline"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "country"
    t.string   "state"
    t.string   "city"
    t.integer  "connections_count",      :default => 0
    t.integer  "privacy_connected"
    t.integer  "privacy_recruiter"
    t.text     "notification_intervals"
    t.string   "occupation"
    t.integer  "years_teaching"
    t.boolean  "job_seeking",            :default => false
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["slug"], :name => "index_users_on_slug", :unique => true

  create_table "users_groups", :force => true do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "permissions", :default => 0
  end

  create_table "video_views", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "video_id",   :null => false
    t.integer  "job_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "video_views", ["video_id"], :name => "index_video_views_on_video_id"

  create_table "videos", :force => true do |t|
    t.string   "video_id",                                        :null => false
    t.string   "description"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "secret_url"
    t.string   "thumbnail_file_name"
    t.string   "thumbnail_content_type"
    t.integer  "thumbnail_file_size"
    t.datetime "thumbnail_updated_at"
    t.string   "video_file_name"
    t.string   "video_content_type"
    t.integer  "video_file_size"
    t.datetime "video_updated_at"
    t.string   "job_id"
    t.string   "encoded_state",          :default => "unencoded"
    t.string   "output_url"
    t.integer  "duration_in_ms"
    t.string   "aspect_ratio"
    t.boolean  "is_snippet",             :default => false,       :null => false
    t.integer  "user_id"
    t.string   "thumbnail_url"
    t.boolean  "featured",               :default => false
  end

  create_table "videos_skills", :id => false, :force => true do |t|
    t.integer "video_id"
    t.integer "skill_id"
  end

  create_table "vouched_skills", :force => true do |t|
    t.integer  "vouch_id"
    t.integer  "skill_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "voucher_id"
  end

  create_table "vouches", :force => true do |t|
    t.integer  "vouchee_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "company"
    t.string   "title"
    t.boolean  "pending",          :default => true
    t.string   "url"
    t.boolean  "for_new_educator", :default => false
  end

  create_table "whiteboards", :force => true do |t|
    t.string   "slug"
    t.text     "message"
    t.integer  "user_id"
    t.string   "tag"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "whiteboards_hidden", :id => false, :force => true do |t|
    t.integer "whiteboard_id"
    t.integer "user_id"
  end

  create_table "winks", :force => true do |t|
    t.integer  "teacher_id", :null => false
    t.integer  "job_id",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "winks", ["job_id"], :name => "index_winks_on_job_id"
  add_index "winks", ["teacher_id"], :name => "index_winks_on_teacher_id"

end
