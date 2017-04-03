class CreatePosts < ActiveRecord::Migration[5.0]
  def change
     #Создание таблицы stylists с полями в БД
    create_table :posts do |t|
      t.text :author
      t.text :content
           
      t.timestamps #добавление полей дата создания и дата изменения
    end
    
    create_table :comments do |t|
      t.text :content
      t.integer :post_id
           
      t.timestamps #добавление полей дата создания и дата изменения
    end  
  end
end
