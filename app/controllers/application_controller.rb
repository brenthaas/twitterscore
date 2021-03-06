class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from 'ActionController::ParameterMissing' do |exception|
    render json: {error: exception.message}, status: 422
  end

  rescue_from 'Twitter::Error::TooManyRequests' do |exception|
    render json: {error: exception.message}, status: 429
  end

  rescue_from 'Twitter::Error::NotFound' do |exception|
    render json: {error: exception.message}, status: 404
  end

  def twitter_client
    Twitter::REST::Client.new do |config|
      config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
    end
  end
end
