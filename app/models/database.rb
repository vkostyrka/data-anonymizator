# frozen_string_literal: true

class Database < ApplicationRecord
  belongs_to :user
  has_many :anonymized, class_name: 'Database', foreign_key: 'original_id', dependent: :delete_all
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
    new_database = Database.create!(attributes.merge(id: nil, original: self, file: file))
    old_database = self

    database 'vrg' do
      strategy DataAnon::Strategy::Blacklist
      source_db adapter: 'sqlite3', database: "public#{new_database.file.url}"
      destination_db adapter: 'sqlite3', database: "public#{old_database.file.url}"

      table 'Employee' do
        skip do |_index, record|
          puts record
          puts record['Title']

          record['Title'] == 'Sales Support Agent'
        end

        primary_key 'EmployeeId'
        anonymize('BirthDate').using FieldStrategy::DateTimeDelta.new(1, 1)
        anonymize('FirstName').using FieldStrategy::RandomFirstName.new
        anonymize('LastName').using FieldStrategy::RandomLastName.new
        anonymize('HireDate').using FieldStrategy::DateTimeDelta.new(2, 0)
        anonymize('Address').using FieldStrategy::RandomAddress.region_US
        anonymize('City').using FieldStrategy::RandomCity.region_US
        anonymize('State').using FieldStrategy::RandomProvince.region_US
        anonymize('PostalCode').using FieldStrategy::RandomZipcode.region_US
        anonymize('Country') { |_field| 'USA' }
        anonymize('Phone').using FieldStrategy::RandomPhoneNumber.new
        anonymize('Fax').using FieldStrategy::RandomPhoneNumber.new
        anonymize('Email').using FieldStrategy::StringTemplate.new('test+2@gmail.com')
      end
    end
  end
end
