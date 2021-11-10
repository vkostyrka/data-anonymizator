# frozen_string_literal: true

class Database < ApplicationRecord
  belongs_to :user
  has_many :anonymized, class_name: 'Database', foreign_key: 'original_id'
  belongs_to :original, class_name: 'Database', optional: true

  enum dbms_type: { sqlite: 0 }
  mount_uploader :file, FileUploader

  def sqlite_database
    SQLite3::Database.new(file.file.file)
  end

  def table_names
    sqlite_database.execute("SELECT name FROM sqlite_schema WHERE type='table' AND name NOT LIKE 'sqlite_%';").flatten
  end

  def table_columns(table_name)
    sqlite_database.table_info(table_name).map { |table| table['name'] }
  end

  def table_data(table_name)
    sqlite_database.execute("SELECT * FROM #{table_name}")
  end

  def call_anonymize
    true
  end
end
