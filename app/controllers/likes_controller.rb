class LikesController < ApplicationController
  def index
  end

  def create
    @like = Like.create(user_id: current_user.id, item_id: params[:item_id])
    @likes = Like.where(item_id: params[:item_id])
    get_item
  end

  def destroy
    @like = Like.find_by(user_id: current_user.id, item_id: params[:item_id])
    @like.destroy
    @likes = Like.where(item_id: params[:item_id])
    get_item
  end

  def get_item
    @item = Item.find(params[:item_id])
  end

  def like_user(user_id)
    likes.find_by(user_id: user_id)
  end

  
  
end