class UsersController < ApplicationController

  def profile
    handle = params.require(:handle)
    user = twitter_client.user(handle)
    render json: user
  end
end
