class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :salt
      t.string :username
      t.string :fullname
      t.string :hash_password
      t.string :email
      t.string :address
      t.date :dob
      t.timestamps null: false
    end
  end
end
