class CreateBlackLists < ActiveRecord::Migration[6.1]
  def change
    create_table :black_lists do |t|
      t.string :jwt
      t.datetime :expiration

      t.timestamps
    end
  end
end
