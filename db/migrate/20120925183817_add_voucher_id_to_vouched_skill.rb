class AddVoucherIdToVouchedSkill < ActiveRecord::Migration
  def change
    add_column :vouched_skills, :voucher_id, :integer

    VouchedSkill.all.each do |vouched_skill|
      if vouched_skill.vouch == nil
		  vouched_skill.destroy
      end
    end
  end
end
