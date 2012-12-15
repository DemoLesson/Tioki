class JobPack < ActiveRecord::Base
	attr_accessible :group, :jobs, :expiration, :inception, :charge_token, :card_token, :refunded, :amount, :additiona_data

	belongs_to :group

	def self.jobAllowance
		query = group(:group_id).select(:group_id).select("SUM(`jobs`) as 'jobs'")
		query = query.where("('#{Time.now.to_s(:db)}' BETWEEN `inception` AND `expiration` && `inception` IS NOT NULL) || (`expiration` > '#{Time.now.to_s(:db)}')")
	end

	def self.disableExpired
		select(:group_id).collect{|jp|unpub=jp.group.jobs.where(:status=>'running').order('`updated_at` DESC').all;jobs=unpub.pop(jp.jobs);unpub.each{|j|j.update_attribute(:status,'unpublished')};jobs}
	end
end