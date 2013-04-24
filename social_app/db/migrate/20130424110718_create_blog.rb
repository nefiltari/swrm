class CreateBlog < ActiveRecord::Migration
  def up
    create_table :blogs do |t|
      t.string :name
      t.text :desc
      t.text :comments
      t.timestamps
    end
  end

  def down
    drop_table :blogs
  end
end
