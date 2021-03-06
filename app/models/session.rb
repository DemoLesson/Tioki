class Session < ActiveRecord::Base
  def self.sweep(time = 1.hour)
    if time.is_a?(String)
      time = time.split.inject { |count, unit| count.to_i.send(unit) }
    end
 
    delete_all "((`updated_at` < '#{time.ago.to_s(:db)}' OR `created_at` < '#{2.days.ago.to_s(:db)}') && `remember` IS NULL) || (`remember` = '1' && `created_at` < '#{1.week.ago.to_s(:db)}')"
  end
end