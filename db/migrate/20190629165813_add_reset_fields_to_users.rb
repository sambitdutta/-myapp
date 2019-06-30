class AddResetFieldsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :reset_token_digest, :string
    add_column :users, :reset_token_sent_at, :datetime
  end
end
