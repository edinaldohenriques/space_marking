class Searches::UsersController < ApplicationController
  def index
    @users = User.where("name ILIKE :query", query: "%#{params[:q]}%").order(:name)
    # @users = User.where("name ILIKE :query AND id != :current_user_id", query: "%#{params[:q]}%", current_user_id: current_user.id).order(:name)
  end
end
