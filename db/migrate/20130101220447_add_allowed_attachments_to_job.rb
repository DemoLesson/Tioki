class AddAllowedAttachmentsToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :allow_videos, :boolean, :default => true
    add_column :jobs, :allow_attachments, :boolean, :default => true
  end
end
