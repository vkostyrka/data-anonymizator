# frozen_string_literal: true

module DatabaseHelper
  require 'csv'
  require 'sequel'

  def convert_csv_to_sqlite(databaseCSV)
    database_tmp_path = "#{databaseCSV.file.identifier}.sqlite"
    gem_db = getDatabase(database_tmp_path)

    populateTableFromCSV(gem_db, databaseCSV.file.file.file)

    databaseCSV.update(file: File.open(database_tmp_path))
    File.delete(database_tmp_path)
  end

  def getDatabase(filename)
    puts "Connecting to sqlite://#{filename}"
    database = Sequel.sqlite(filename)
    # database.test_connection # saves blank file
    database
  end

  def populateTableFromCSV(database,filename)
    options = { :headers    => true,
                :header_converters => :symbol,
                :converters => :all  }
    data = CSV.table(filename, options)
    headers = data.headers
    tablename = File.basename(filename, '.csv').gsub(/[^0-9a-zA-Z_]/,'_').to_sym

    puts "Dropping and re-creating table #{tablename}"
    database.drop_table? tablename
    database.create_table tablename do
      # see http://sequel.rubyforge.org/rdoc/files/doc/schema_modification_rdoc.html
      # primary_key :id
      # Float :price
      data.by_col!.each do |columnName,rows|
        # column_type = get_common_class(rows) || String
        column(columnName, String)
      end
    end
    data.by_row!.each do |row|
      database[tablename].insert(row.to_hash)
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
    rows.map(&:class).max_by {|i| rows.map(&:class).count(i)}
  end
end
