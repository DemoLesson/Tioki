class AddJobAllowanceToGroups < ActiveRecord::Migration
  def up
  	create_table :job_packs do |t|

  		# Group ID and Job Allowance
  		t.integer :group_id
  		t.integer :jobs

  		# Add a time that the expiration ends
  		t.datetime :expiration

  		# Stripe data
  		t.string :charge_token
  		t.string :card_token
  		t.integer :refunded
  		t.integer :amount

  		# Whatever else
  		t.text :additional_data
  	end
  end
  def down
  	drop_table :job_packs
  end
end
