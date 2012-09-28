class RemoveVoucherIdFromVouch < ActiveRecord::Migration
  def up
    remove_column :vouches, :voucher_id
  end

  def down
    add_column :vouches, :voucher_id, :integer
  end
end
