class PostsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]
  before_action :set_skill, only: :create, if: :skill? # before the 'create' method, call to 'set_skill' only if there is a skill
  before_action :set_role, only: :create, if: :role?
  before_action :set_params, only: %i[upvote show]
  before_action :set_vote, only: %i[show upvote]

  def show
    @author = Profile.find_by(user_id: @post.user_id)
    @bookmark = @post.bookmarks.find_by(user: current_user) || Bookmark.new
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    @post.user = current_user
    @post.postable = @postable
    if @post.save
      redirect_to post_path(@post)
    else
      render :new
    end
  end

  def index
    if params[:type]
      @postable = (params[:type] == "Role" ? Role : Skill).find(params[:postable_id])
      @posts = Post.where(postable_type: params[:type], postable_id: params[:postable_id])
    else
      @posts = [] # once we validate search works this 'else' should not show anything
    end
  end

  private

  def set_vote
    @vote = @post.votes.find_by(user: current_user)
  end

  def role?
    params[:tag][:postableSkills].empty?
  end

  def skill?
    params[:tag][:postableRoles].empty?
  end

  def set_skill
    @postable = Skill.find(params[:tag][:postableSkills])
  end

  def set_role
    @postable = Role.find(params[:tag][:postableRoles])
  end

  def post_params
    params.require(:post).permit(:title, :blurb, :rich_content, photos: [])
  end

  def set_params
    @post = Post.find(params[:id])
  end
end
