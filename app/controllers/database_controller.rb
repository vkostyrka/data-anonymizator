# frozen_string_literal: true

class DatabaseController < ApplicationController
  before_action :authenticate_user!

  def index
    @datasets = Database.where(user: current_user)
  end
end
