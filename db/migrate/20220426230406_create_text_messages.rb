class CreateTextMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :text_messages do |t|
      t.text :text, null: false
      t.string :sms_message_id
      t.string :to_number
      t.string :status, null: true
      t.boolean :resolved, default: false
      t.timestamps
    end
  end
end
