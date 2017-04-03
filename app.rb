#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'
require 'sinatra/activerecord'

#Устанавливаем соединение с БД barbershop.db
set :database, "sqlite3:public/posts.db"

#Cоздание модели БД в классе Post
class Post < ActiveRecord::Base
  has_many :comments
	validates :content, presence: true
end

class Comment < ActiveRecord::Base
	belongs_to :post
	validates :content, presence: true
end

get '/' do  
  @results = Post.order "id DESC" #выбор списка постов из БД (ввиде хэша)
  erb :index
end

post '/' do
  erb :index
end

get '/new' do #обработчик get запроса /new (формирует страницу)
  erb :new #возвращаем представление new.erb
end

post '/new' do #обработчик post запроса /new
  #Принимаем данные со страницы /visit (ActiveRecird)
  @c=Post.new params[:pst]
    
  #Сохраняем данные в таблицу, если прошли валидацию
  if @c.save
	  erb "<h2>Thanks, You have been added!</h2>"
  else
	  #Иначе выводит первый элемент из массива ошибок
	  @error = @c.errors.full_messages.first
	  erb :new
  end
end

get '/comment/:post_id' do #обработчик get запроса для url`а (формирует страницы)
  #получаем переменную из url`а
  post_id = params[:post_id]
  
  #получаем список постов - у нас будет только один пост по этому номеру
  @result = Post.find(params[:post_id])
  #выбираем комментарии для нашего поста
	@comments = Comment.all.where post_id: post_id
  
  erb :comments
end

post '/comment/:post_id' do #обработчик post запроса для url`а
	#получаем переменную из url`а
  post_id = params[:post_id]
  
	# получаем содержание комментария и записываем в переменную БД
	@d = Comment.new params[:cmt]
	# добавляем в переменную номер поста из параметров урл-а
	@d.post_id = post_id
  
  #Сохраняем данные в таблицу, если прошли валидацию
    if @d.save
			redirect to ('/comment/' + post_id)
  	else
  		#Иначе выводит первый элемент из массива ошибок
		  @error = @d.errors.full_messages.first
		  erb :comments
		end
end

get '/:post_id' do #обработчик get запроса от form action="/" в index.erb (формирует страницу)
  erb :index
end

delete '/:post_id' do #обработчик post запроса delete
	#получаем переменную из url`а
	post_id = params[:post_id]

  #получаем пост и удаяем его
	Post.find(params[:post_id]).destroy
	#выбираем все комментарии для нашего поста и удаляем
	Comment.where(post_id: post_id).destroy_all

	redirect to ('/')
end
