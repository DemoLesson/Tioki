class AddVoucherIdToVouch < ActiveRecord::Migration
  def change
    add_column :vouches, :voucher_id, :integer
  end
end
