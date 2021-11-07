# frozen_string_literal: true

class DatabaseController < ApplicationController
  before_action :authenticate_user!

  def index
    @databases = Database.where(user: current_user)
  end

  # def show
  #   @dataset = Dataset.find(params[:id])
  #
  #   redirect_to root_path, alert: "It's not your dataset" unless current_user.id == @dataset.user_id
  #
  #   @filters = @dataset.filters.where.not(filtered_id: [0]).each(&:filter_name)
  #   @headers = @dataset.headers
  #   @counts = @dataset.counts
  #
  #   @data = prepare_data(params, @dataset)
  #
  #   respond_to do |format|
  #     format.html
  #     format.json { render json: { data: @data } }
  #   end
  # end

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
