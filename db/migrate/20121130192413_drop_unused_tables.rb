class DropUnusedTables < ActiveRecord::Migration
  def change
    drop_table :stars
    drop_table :pins
  end
end
