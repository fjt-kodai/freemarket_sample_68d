class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable


  has_many :items, dependent: :destroy
  has_many :orders
  has_many :likes, dependent: :destroy
  has_many :like_items, through: :likes, source: :story
  has_one :credit_card
  has_one :address

  validates :nickname, :first_name, :last_name, :birthday, presence: true
  validates :email, presence: true,
            uniqueness: true,
            format: {
            with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i,
            message: "は正しく入力してください。"
          },
          on: :create
  validates :password, presence: true,
            length: { minimum: 7 },
            format: {
              with: /\A(?=.*?[a-z])(?=.*?\d)[a-zA-Z\d]+\z/,
              message: "は英字と数字の両方を含めて下さい。"
            },
            on: :create
  validates :first_furigana, :last_furigana, presence: true,
            format: {
              with: /\A[\p{katakana}ー－&&[^ -~｡-ﾟ]]+\z/,
              message: "は全角カタカナのみで入力して下さい。"
            }
end
