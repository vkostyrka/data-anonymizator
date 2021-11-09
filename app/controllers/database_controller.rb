# frozen_string_literal: true

class DatabaseController < ApplicationController
  before_action :authenticate_user!

  def index
    @databases = Database.where(user: current_user)
  end

  def show
    @database = Database.find(params[:id])

    redirect_to root_path, alert: "It's not your database" unless current_user.id == @database.user_id

    @tables_names = @database.table_names
    @current_table_name = params[:table_name] || @tables_names[0]
    @current_table_columns = @database.table_columns(@current_table_name)
    @current_table_data = @database.table_data(@current_table_name)
  end

  def create
    @database = Database.new(database_params.merge(user: current_user))
    if @database.save
      redirect_to root_path, notice: 'Your database successful added'
    else
      redirect_to root_path, alert: 'Your database not added'
    end
  end

  def destroy
    @database = Database.find(params[:id])
    redirect_to root_path, alert: "It's not your database" unless current_user.id == @database.user_id
    if @database.destroy
      redirect_to root_path, notice: 'Your database successfully deleted'
    else
      redirect_to root_path, notice: "Your database wasn't deleted"
    end
  end

  private

  def database_params
    params.require(:database).permit(:dbms_type, :file)
  end
end
