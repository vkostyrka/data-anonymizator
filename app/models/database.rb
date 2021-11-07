# frozen_string_literal: true

class Database < ApplicationRecord
  belongs_to :user
  enum dbms_type: { sqlite: 0 }
  mount_uploader :file, FileUploader

  def get_sqlite
    SQLite3::Database.new(self.file.file.file)
  end

  def table_names
    get_sqlite.execute("SELECT name FROM sqlite_schema WHERE type='table' AND name NOT LIKE 'sqlite_%';").flatten
  end
end
