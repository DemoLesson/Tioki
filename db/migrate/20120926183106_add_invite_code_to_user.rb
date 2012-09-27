class AddInviteCodeToUser < ActiveRecord::Migration
	def change
		add_column :users, :invite_code, :string
		User.all.each do |user|
			user_invite = nil
			generated_code = rand(36**7).to_s(36)
			begin
				user_invite = User.find(:first, :conditions => ['invite_code = ?', generated_code])
			end while user_invite != nil
			user.update_attribute(:invite_code, generated_code)
		end
	end
end
