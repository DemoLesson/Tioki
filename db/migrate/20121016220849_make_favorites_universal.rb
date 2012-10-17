class MakeFavoritesUniversal < ActiveRecord::Migration
  def change
  	drop_table :videos_favorites
  	create_table :favorites do |t|
  		t.column :user_id, :integer
      	t.column :model, :string
     	t.timestamps
    end

    change_table :events_rsvps do |t|
    	t.timestamps
  	end
  end
end
