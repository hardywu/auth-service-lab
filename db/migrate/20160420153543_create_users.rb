class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :email, null: true
      t.string :password_digest, null: true
      t.string :phone, null: true
      t.string :pin_digest, null: true

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.inet     :current_sign_in_ip
      t.inet     :last_sign_in_ip

      t.timestamps
    end
  end
end
