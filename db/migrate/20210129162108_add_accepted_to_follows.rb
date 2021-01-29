class AddAcceptedToFollows < ActiveRecord::Migration[6.1]
  def change
    add_column :follows, :accepted, :boolean
  end
end
