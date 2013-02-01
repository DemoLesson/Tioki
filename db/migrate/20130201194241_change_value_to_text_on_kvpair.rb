class ChangeValueToTextOnKvpair < ActiveRecord::Migration
  def up
		change_column :kvpairs, :value, :text
  end

  def down
		change_column :kvpairs, :value, :string
  end
end
