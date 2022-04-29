class AddUserToTextMessages < ActiveRecord::Migration[7.0]
  def change
    change_table :text_messages do |t|
      t.references :sender, null: false, foreign_key: { to_table: "users" }
    end
  end
end
