class AddWebsiteAndBlogToTeacher < ActiveRecord::Migration
  def change
    add_column :teachers, :website, :string
    add_column :teachers, :blog, :string
  end
end
