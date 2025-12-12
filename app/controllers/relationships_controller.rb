class RelationshipsController < ApplicationController
  before_action :logged_in_user
  def create
    @user = User.find(params[:followed_id])
    current_user&.follow(@user)
    # Users Turbo-stream which we have installed.
    # Normally, we don't respond to Turbo streams
    # so Rails defaults to responding as if they are
    # regular HTML requests
    respond_to do |format|
      format.html { redirect_to @user }
      format.turbo_stream
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user&.unfollow(@user)
    respond_to do |format|
      format.html { redirect_to @user, status: :see_other }
      format.turbo_stream
    end
  end
end
