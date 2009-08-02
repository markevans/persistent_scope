class MigrationForTest < ActiveRecord::Migration
  
  def self.up
    create_table :blogs, :force => true do |t|
      t.string :title
      t.boolean :published
      t.timestamps
    end
    
    create_table :posts, :force => true do |t|
      t.string :title
      t.string :body
      t.integer :blog_id
      t.timestamps
    end
    
    create_table :comments, :force => true do |t|
      t.string :body
      t.integer :post_id
      t.timestamps
    end
  end

  def self.down
    drop_table :comments
    drop_table :posts
    drop_table :blogs
    
  end

end
