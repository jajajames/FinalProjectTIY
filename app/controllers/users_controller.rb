class UsersController < ApplicationController
  skip_before_action :require_email_confirmation, only: [:new, :create, :confirm_email]
  skip_before_action :require_quest,              only: [:new, :create, :confirm_email]
  before_action :disallow_user, only: [:new, :create]
  before_action :require_user,  only: [:show, :edit, :update]
  before_action :get_user,      only: [:show, :edit, :update]
  before_action :correct_user,  only: [:show, :edit, :update]
  rescue_from ActiveRecord::RecordNotFound, with: :dude_wheres_my_record

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:current_user_id] = @user.id
      if @user.contact_pref == "phone"
        register_authy
      elsif @user.contact_pref == "email"
        UserNotifier.registration_confirmation(@user).deliver_now
        flash[:success] = "New user #{current_user.name} created please check your email #{@user.email} and click link."
        redirect_to :root
      else
        flash[:success] = "New user #{current_user.name} created"
        redirect_to :journey_new
      end
    else
      flash.now[:warning] = "Could not save account. Please see #{"error".pluralize(@user.errors.count)} below"
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      flash[:success] = "User #{current_user.name} updated"
      redirect_to @user
    else
      flash.now[:warning] = "Could not save account. Please see #{"error".pluralize(@user.errors.count)} below"
      render :edit
    end
  end

  def confirm_email
    if current_user
      current_user.email_activate
      session[:current_user_id] = current_user.id
      flash[:success] = "Welcome to the website! Your email has been confirmed.
      You are signed in."
    else
      flash[:error] = "Sorry. User does not exist"
    end
    redirect_to root_url
  end

  private

  def get_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(
      :email, :cellphone, :contact_pref, :name,
      :password, :password_confirmation)
  end

  def register_authy
    authy = Authy::API.register_user(:email => current_user.email, :cellphone => current_user.unamericanized_cell, :country_code => "1")

    if authy.ok?
      current_user.update_attribute(:authy_id, authy.id)
      send_token_id
    else
      authy.errors
      flash[:warning] = authy.errors.inspect
      render :new
    end
  end

  def send_token_id
    response = Authy::API.request_sms(:id => current_user.authy_id)

    if response.ok?
      flash[:success] = "User '#{current_user.name}' created"
      redirect_to new_phone_verification_path
    else
      response.errors
      flash["error"] = response.errors.inspect
      render :new
    end
  end
end
