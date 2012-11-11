# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Preview::Application.initialize!

# # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# Action Mailer Deliver With SMTP
#
# ActionMailer::Base.delivery_method = :smtp
#
#
# Gmail SMTP Settings
#
# ActionMailer::Base.smtp_settings = {
#   :tls => true,
#   :address => "smtp.gmail.com",
#   :port => 587,
#   :domain => "demolesson.com",
#   :authentication => :plain,
#   :user_name => "demolesson@demolesson.com",
#   :password => "Preview1"
# }
#
#
# Send Grid SMTP Settings
#
# ActionMailer::Base.smtp_settings = {
#   :tls => true,
#   :user_name => "demolesson",
#   :password => "Preview1",
#   :domain => "demolesson.com",
#   :address => "smtp.sendgrid.net",
#   :authentication => :plain,
#   :port => 587,
#   :authentication => :plain,
#   :enable_starttls_auto => true
# }
# # # # # # # # # # # # # # # # # # # # # # # # # # # #

# # #
# Mail Gun Delivery Settings in /config/application.rb
# # #

YEARS_ARRAY = (1940..Time.now.year+5).entries

STATES_ARRAY = [ "Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming", "Washington DC" ]

STATES_ARRAY_AB = [
     "AL",
     "AK",
     "AZ",
     "AR",
     "CA",
     "CO",
     "CT",
     "DE",
     "FL",
     "GA",
     "HI",
     "ID",
     "IL",
     "IN",
     "IA",
     "KS",
     "KY",
     "LA",
     "ME",
     "MD",
     "MA",
     "MI",
     "MN",
     "MS",
     "MO",
     "MT",
     "NE",
     "NV",
     "NH",
     "NJ",
     "NM",
     "NY",
     "NC",
     "ND",
     "OH",
     "OK",
     "OR",
     "PA",
     "RI",
     "SC",
     "SD",
     "TN",
     "TX",
     "UT",
     "VT",
     "VA",
     "WA",
     "WV",
     "WI",
     "WY",
     "DC"
  ]
MONTHS_ARRAY = [ "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

Time::DATE_FORMATS[:due_time] = "%B %d, %Y at %I:%M %p"
Time::DATE_FORMATS[:interview_time] = "%B %d, %Y, %I:%M %p"
Time::DATE_FORMATS[:message_time] = "%B %d, %Y - %I:%M %p"
Time::DATE_FORMATS[:job_time] = "%B %d, %Y"
Time::DATE_FORMATS[:jobpicker_time] = "%m/%d/%Y"
TIOKI_BUCKS_START="2012-11-11 20:00:00"
