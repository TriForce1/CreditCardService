class CreateCreditCards < ActiveRecord::Migration
  def change
    create_table :credit_cards do |t|
      t.string :credit_card
      t.text :parameters
      t.timestamps null: false
    end
  end
end
