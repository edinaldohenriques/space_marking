class Searches::UsersController < ApplicationController
  def index
    @users = User.where("name ILIKE :query AND confirmed_at IS NOT NULL AND user_type != :user_type", 
                  query: "%#{params[:q]}%", 
                  user_type: 1).order(:name)

    # @users = User.where("name ILIKE :query AND confirmed_at IS NOT NULL AND id != :current_user_id", query: "%#{params[:q]}%", current_user_id: current_user.id).order(:name)

    # @users = User.where("name ILIKE :query", query: "%#{params[:q]}%").order(:name)
    # @users = User.where("name ILIKE :query AND id != :current_user_id", query: "%#{params[:q]}%", current_user_id: current_user.id).order(:name)
  end
end
