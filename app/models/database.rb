# frozen_string_literal: true

class Database < ApplicationRecord
  belongs_to :user
  has_many :anonymized, class_name: 'Database', foreign_key: 'original_id', dependent: :delete_all
  belongs_to :original, class_name: 'Database', optional: true

  enum dbms_type: { sqlite: 0, csv: 1 }
  mount_uploader :file, FileUploader

  STRATEGIES = {
    first_name:  FieldStrategy::RandomFirstName.new,
    last_name:   FieldStrategy::RandomLastName.new,
    full_name:   FieldStrategy::RandomFullName.new,
    date_time:   FieldStrategy::DateTimeDelta.new(2, 0),
    address:     FieldStrategy::RandomAddress.region_US,
    city:        FieldStrategy::RandomCity.region_US,
    zip_code:    FieldStrategy::RandomZipcode.region_US,
    province:    FieldStrategy::RandomProvince.region_US,
    phone:       FieldStrategy::RandomPhoneNumber.new,
    email:       FieldStrategy::RandomEmail.new,
    big_decimal: FieldStrategy::RandomBigDecimalDelta.new,
    bool:        FieldStrategy::RandomBoolean.new,
    integer:     FieldStrategy::RandomInteger.new,
    float:       FieldStrategy::RandomFloat.new,
    string:      FieldStrategy::RandomString.new,
    url:         FieldStrategy::RandomUrl.new
  }.freeze

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

  def get_pk_column_name(table_name)
    if (pk_column = sqlite_database.table_info(table_name).find { |column| column['pk'] == 1 })
      return pk_column['name']
    end

    if (pk_column = sqlite_database.table_info(table_name).find { |column| column['name'].include? '_id' })
      return pk_column['name']
    end

    sqlite_database.table_info(table_name).first["name"]
  end

  def call_anonymize(params)
    new_database = Database.create!(attributes.merge(id: nil, original: self, file: file))
    old_database = self

    database new_database.file.identifier do
      strategy DataAnon::Strategy::Blacklist
      source_db adapter: 'sqlite3', database: "public#{new_database.file.url}"
      destination_db adapter: 'sqlite3', database: "public#{old_database.file.url}"

      table params['table_name'] do
        primary_key new_database.get_pk_column_name(params['table_name'])

        params['strategies'].each_key do |column_name|
          strategy_name = params['strategies'][column_name].to_sym
          anonymize(column_name).using STRATEGIES[strategy_name]
        end
      end
    end
  end
end
