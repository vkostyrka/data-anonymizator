class CreateDatabases < ActiveRecord::Migration[6.1]
  def change
    create_table :databases do |t|
      t.integer :dbms_type, null: false
      t.belongs_to :user

      t.timestamps
    end
  end
end
