class AddFileToDatabase < ActiveRecord::Migration[6.1]
  def change
    add_column :databases, :file, :string
  end
end
