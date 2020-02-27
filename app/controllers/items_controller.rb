class ItemsController < ApplicationController
  before_action :authenticate_user!, expect: [:show]
  before_action :set_item, only: [:show ,:destroy]

  def show
    @item_image = @item.item_images[0].url.ur
    @next_id = set_page(@item.id + 1)
    @prev_id = set_page(@item.id - 1)
  end

  def new
    @item = Item.new
    @item.item_images.new
    @parent_categories = Category.where(ancestry: nil)

    respond_to do |format|
      format.html
      format.json {@child_categories = Category.find(params[:category_id]).children}
    end
  end


  def create
    @item = Item.new(item_params)

    if @item.save
      redirect_to root_path
    else
      @item.item_images.new
      render :new
    end
  end

  def destroy
    if current_user.id == @item.user_id && @item.destroy
      render template: "items/destroy"
    else
      redirect_back(fallback_location: root_path)
    end
  end


  private
  
  def item_params
    params.require(:item).permit(:name, :description, :category_id, :price, :condition_id , :shipping_fee_who_id, :prefecture_id, :shipping_days_id, item_images_attributes: [:url] ).merge(user_id: current_user.id)
  end

  def set_item
    @item = Item.find(params[:id])
  end

  def set_page(item_id)
    next_id = Item.where("user_id = ? and id = ?", @item.user_id, item_id)
    next_id.present? ? next_id[0].id : @item.id
  end
end
