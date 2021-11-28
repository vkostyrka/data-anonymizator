# frozen_string_literal: true

module DatabaseHelper
  require 'csv'
  require 'sequel'

  def convert_csv_to_sqlite(database_csv)
    database_tmp_path = "#{database_csv.file.identifier}.sqlite"
    gem_db = get_sequel_database(database_tmp_path)

    populate_table_from_csv(gem_db, database_csv.file.file.file)

    database_csv.update(file: File.open(database_tmp_path))
    File.delete(database_tmp_path)
  end

  def get_sequel_database(filename)
    puts "Connecting to sqlite://#{filename}"
    Sequel.sqlite(filename)
  end

  def populate_table_from_csv(database, filename)
    options = { headers:           true,
                header_converters: :symbol,
                converters:        :all }
    data = CSV.table(filename, options)
    headers = data.headers
    table_name = File.basename(filename, '.csv').gsub(/[^0-9a-zA-Z_]/, '_').to_sym

    puts "Dropping and re-creating table #{table_name}"
    database.drop_table? table_name
    database.create_table table_name do
      # see http://sequel.rubyforge.org/rdoc/files/doc/schema_modification_rdoc.html
      # primary_key :id
      # Float :price
      data.by_col!.each do |column_name, _rows|
        # column_type = get_common_class(rows) || String
        column(column_name, String)
      end
    end
    data.by_row!.each do |row|
      database[table_name].insert(row.to_hash)
    end
  end

  #
  # :call-seq:
  #   getCommonClass([1,2,3])         => FixNum
  #   getCommonClass([1,"bob",3])     => String
  #
  # Returns the class of each element in +rows+ if same for all elements, otherwise returns nil
  #
  def get_common_class(rows)
    rows.map(&:class).max_by { |i| rows.map(&:class).count(i) }
  end
end
