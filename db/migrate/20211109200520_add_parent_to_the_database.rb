class AddParentToTheDatabase < ActiveRecord::Migration[6.1]
  def change
    add_column :databases, :original_id, :bigint,foreign_key: { to_table: :databases }, index: true, null: true
  end
end
