class FeaturedVideosOnTeacher < ActiveRecord::Migration
  def up
  	add_column :teachers, :video_id, :integer
  	remove_column :teachers, :video_embed_html
  	remove_column :teachers, :video_embed_url
  end

  def down
  	remove_column :teachers, :video_id
  	add_column :teachers, :video_embed_html, :string
  	add_column :teachers, :video_embed_url, :string
  end
end
