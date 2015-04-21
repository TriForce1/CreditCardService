class CreateCreditCards < ActiveRecord::Migration
  def change
    create_table :credit_cards do |t|
      t.string :number
      t.string :owner
      t.date :expiration_date
      t.string :credit_network
      t.timestamps null: false
    end
  end
end
