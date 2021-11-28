# frozen_string_literal: true

class DatabaseController < ApplicationController
  before_action :authenticate_user!
  before_action :database, only: %i[destroy anonymize download_file show]
  skip_before_action :verify_authenticity_token, only: %i[anonymize]

  def index
    @databases = Database.where(user: current_user, original_id: nil)
    @anonymized_databases = Database.where(user: current_user).where.not(original_id: nil)
  end

  def show
    @tables_names = @database.table_names
    @current_table_name = params[:table_name] || @tables_names[0]
    @current_table_columns = @database.table_columns(@current_table_name)
    @current_table_data = @database.table_data(@current_table_name)
    @current_table_primary_key = @database.get_pk_column_name(@current_table_name)
  end

  def create
    @database = Database.new(database_params.merge(user: current_user))
    if @database.save
      helpers.convert_csv_to_sqlite(@database) if @database.csv?
      redirect_to root_path, notice: 'Your database successful added'
    else
      redirect_to root_path, alert: 'Your database not added'
    end
  end

  def destroy
    if @database.destroy
      redirect_to root_path, notice: 'Your database successfully deleted'
    else
      redirect_to root_path, notice: "Your database wasn't deleted"
    end
  end

  def anonymize
    if @database.call_anonymize(database_anonymize_params)
      render json: { success: true }
    else
      render json: { success: false }
    end
  end

  def download_file
    send_file(@database.file.file.file)
  end

  private

  def database
    @database = Database.find(params[:database_id] || params[:id])
    redirect_to root_path, alert: "It's not your database" unless current_user.id == @database.user_id
  end

  def database_params
    params.require(:database).permit(:dbms_type, :file)
  end

  def database_anonymize_params
    params.require(:database).permit(:table_name, :primary_key, strategies: {})
  end
end
