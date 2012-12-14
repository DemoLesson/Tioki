class Wink < ActiveRecord::Base
  belongs_to :teacher
  belongs_to :job
end
