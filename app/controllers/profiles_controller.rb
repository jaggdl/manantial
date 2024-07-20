class ProfilesController < ApplicationController
  before_action :set_profile, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  def show
  end

  def new
    if Profile.exists?
      redirect_to root_path, notice: 'Profile already exists.'
    else
      @profile = Profile.new
    end
  end

  def create
    if Profile.exists?
      redirect_to root_path, notice: 'Profile already exists.'
    else
      @profile = Profile.new(profile_params)
      if @profile.save
        redirect_to root_path, notice: 'Profile was successfully created.'
      else
        render :new
      end
    end
  end

  def edit
  end

  def update
    if @profile.update(profile_params)
      redirect_to root_path, notice: 'Profile was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @profile.destroy
    redirect_to new_root_path, notice: 'Profile was successfully destroyed.'
  end

  private

  def set_profile
    @profile = Profile.first_or_initialize
  end

  def profile_params
    params.require(:profile).permit(:full_name, :short_name, :description, :info, :profile_picture)
  end
end
