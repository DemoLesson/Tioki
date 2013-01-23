class AddAttachmentTable < ActiveRecord::Migration
	def up
		create_table :attachments do |t|

			# Relationships
			t.integer :owner_id
			t.string  :owner_type

			# File Information
			t.attachment :file

			# Link to a video if applicable
			t.integer :video_id

			# Additional Data
			t.text :data

			# Timestamps
			t.timestamps
		end
	end

	def down

		# Drop the whole table
		drop_table :attachments
	end
end
