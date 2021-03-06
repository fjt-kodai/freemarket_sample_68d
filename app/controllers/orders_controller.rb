class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item
  require 'payjp'
  include CardsHelper

  def new
    card = CreditCard.where(user_id: current_user.id).first
    #Cardテーブルは前回記事で作成、テーブルからpayjpの顧客IDを検索
    if card.blank?
      redirect_to controller: "credit_cards", action: "new"
    else
      Payjp.api_key = ENV["PAYJP_PRIVATE_KEY"]
      #保管した顧客IDでpayjpから情報取得
      customer = Payjp::Customer.retrieve(card.customer_id)
      #保管したカードIDでpayjpから情報取得、カード情報表示のためインスタンス変数に代入
      default_card_information = customer.cards.retrieve(card.card_id)

      #購入者のクレジットカード情報の変数化
      @card_number = "**** **** **** " + default_card_information.last4
      @exp_month = default_card_information.exp_month.to_s.rjust(2, "0")
      @exp_year = default_card_information.exp_year.to_s.slice(2,3)
      @card_name = default_card_information.name.to_s
      @card_brand = card_company(default_card_information.brand)

      #購入者の配送先情報
      address = current_user.address
      @postal_code = address.postal_code
      @address = Prefecture.find(address.prefecture_id).name + address.address1 + address.address2 + address.building_name
      @phone_number = address.phone_number
      #購入商品の画像を変数化
      @item_images = @item.item_images[0].url.url
    end
  end

  def pay #購入処理
    if @item.stock_status
      card = CreditCard.where(user_id: current_user.id).first
      Payjp.api_key = ENV['PAYJP_PRIVATE_KEY']
      Payjp::Charge.create(
        :amount => @item.price, #支払金額を入力
        :customer => card.customer_id, #顧客ID
        :currency => 'jpy', #日本円
      )
      order = Order.new(item_id: @item.id, user_id: current_user.id)
      @item.stock_status = false
      if order.save
        @item.save
        sele_create(order).save
        redirect_to action: 'done' 
      else
        redirect_to action: "pay"
      end
    else
      redirect_to root_path
    end
  end

  private
  def set_item
    @item = Item.find(params[:item_id])
  end

  def sele_create(order)
    profit = @item.price.to_i * 0.9
    category_data = Category.find(@item.category_id)
    parent, child, grandchild = category_set(category_data)
    @item.brand_id.present? ? brand = Brand.find(@item.brand_id) : brand = ""
    Sele.new(
      order_id: order.id,
      item_id: order.item_id,
      user_id: @item.user_id,
      revenue: @item.price.to_i,
      profit: profit.round,
      name: @item.name,
      category: parent,
      subcategory: child,
      subsubcategory: grandchild,
      brand: brand
    )
  end

  def category_set(category)
    if category.ancestry.nil?
      parent = category.name
      child = ""
      grandchild = ""
      return parent, child, grandchild
    elsif category.parent.parent.nil?
      parent = category.parent.name
      child = category.name
      grandchild = ""
      return parent, child, grandchild
    else
      parent = category.parent.parent.name
      child = category.parent.name
      grandchild = category.name
      return parent, child, grandchild
    end
  end
end
