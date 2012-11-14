class AddBanner < ActiveRecord::Migration
  def up
  	create_table :banners do |t|
  		t.string :message
  		t.datetime :start
  		t.datetime :stop
  		t.integer :recurring
  		t.timestamps
  	end
  end

  def down
  	drop_table :banners
  end
end
