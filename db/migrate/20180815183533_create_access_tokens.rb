class CreateAccessTokens < ActiveRecord::Migration
  def change
    create_table :clickfunnels_auth_access_tokens do |t|
      t.string :token
      t.string :refresh_token
      t.timestamp :expires_at
      t.bigint :user_id

      t.timestamps
    end
    add_index :access_tokens, :user_id
  end
end
