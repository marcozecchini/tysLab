class ApplicationsController < ApplicationController

  before_action :logged_in?, except: :show_public
  before_action :is_allowed?, except: :show_public

  # GET /users/:user_id/applications/:id
  def show
    @application = Application.find_by(author: params[:user_id],
                                      id: params[:id])
    render file: "public/404.html" and return unless @application
    #@reports = StackTrace.where(app: @application.id) if @application
    @reports = @application.stack_traces

    # Used to retrieve the github collaborators
    @github_param = @application.github_repository.sub("/", "_") unless @application.github_repository == ""
  end

  # GET /users/:user_id/applications/new
  def new
    @application = Application.new
    repos = SessionHandler.instance.get_repos(current_user)
    @repos = repos.map do |r|
      r[:full_name] if r[:owner][:login] == current_user.name
    end
    @repos.delete nil
    @repos.unshift nil
  end

  # POST /users/:user_id/applications
  def create
    @application = Application.create!(create_params)
    @application.users << current_user
    flash[:notice] = "#{@application.application_name} was successfully created."
  end

  # GET /users/:user_id/applications
  def index
    @invitations = Invitation.where(target_name: current_user)
  end

  # GET /users/:user_id/applications/:application_id/show_public
  def show_public
    @application = Application.find(params[:application_id])
    @feedbacks = @application.feedbacks
  end

  # DELETE /users/:user_id/applications/:id
  def destroy
    @application = Application.find_by(author: params[:user_id], id: params[:id])
    render file: "public/404.html" and return unless @application
    render file: "public/403.html" and return unless @application.author == current_user.name
    @application.destroy
    flash[:notice] = "#{@application.application_name} was successfully deleted."
    redirect_to user_applications_path
  end

  private
  def create_params
    params.require(:application).permit(:application_name, :author,
                                        :programming_language, :github_repository)
  end

  def is_allowed?
    unless params[:user_id] == session[:user_id] || Contributor.find_by(user_id: session[:user_id])
      render file: "public/404.html" and return
    end
  end
end
