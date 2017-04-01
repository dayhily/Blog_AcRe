require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
  @db=SQLite3::Database.new 'testblog.db' #Инициализация БД ввиде массива
  @db.results_as_hash=true #Результат инициализации ввиде хэша, (ключ-название поля, значение-данные поля)
end

before do #Вызывается перед каждым запросом (перезагрузкой любой страницы)
  init_db #Инициализация БД
end

configure do #метод конфигурации приложения вызывается каждый раз при инициализации приложения
             #инициализация происходит при сохранении, изменении файла и обновлении страницы
  init_db #Инициализация БД
  @db.execute 'CREATE TABLE IF NOT EXISTS `posts` (
	`id`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`created_date`	DATE,
	`content`	TEXT)' #создание таблицы в БД если ее нет
  
   @db.execute 'CREATE TABLE IF NOT EXISTS `comments` (
	`id`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`post_id` INTEGER,
	`created_date`	DATE,
	`content`	TEXT)' #создание таблицы в БД если ее нет
end

get '/' do  
  @results = @db.execute 'SELECT * FROM posts ORDER BY ID DESC' #выбор списка постов из БД (ввиде хэша)
  erb :index
end

get '/new' do #обработчик get запроса /new (формирует страницу)
  erb :new #возвращаем представление new.erb
end

post '/new' do #обработчик post запроса /new
  post_content=params[:content] #получаем переменную(параметр) content из post запроса
  
  if post_content.length <= 0 #если переменная post_content пустая, то
    @error = 'Type text'# @error присваивается сообщение об ошибке
    return erb :new #и возвращается представление /new
  end

  #сохранение переменных content и created_date со значениями [post_content] и datetime() в таблицу posts
  @db.execute 'INSERT INTO
    posts (content, created_date)
       values (?, datetime() )', [post_content] 
  
  redirect to '/' #перенаправление на главную страницу после отправки формы
end

get '/comment/:post_id' do #обработчик get запроса для url`а (формирует страницы)
  post_id=params[:post_id] #браузер получает параметр(название страницы) из url`а
  #для каждой ссылки добавляется id поста считанный из url`а.
  result = @db.execute 'SELECT * FROM posts WHERE id = ?', [post_id] #выбор списка постов из БД c определенным id (ввиде хэша)
  @row=result[0] #выбор строки с индексом 0 из списка в переменную @row (т.е. самый первый пост)
  #выбираем комментарии из БД для поста по post_id
  @comments = @db.execute 'SELECT * FROM comments WHERE post_id = ? ORDER BY id', [post_id]
  erb :comments #возвращаем представление comments.erb
end

post '/comment/:post_id' do #обработчик post запроса для url`а
	post_id=params[:post_id] #браузер получает параметр(название страницы) из url`а
  post_content=params[:content] #получаем переменную(параметр) content из post запроса
  
  result = @db.execute 'SELECT * FROM posts WHERE id = ?', [post_id] #выбор списка постов из БД c определенным id (ввиде хэша)
  @row=result[0] #выбор строки с индексом 0 из списка в переменную @row (т.е. самый первый пост)
  #выбираем комментарии из БД для поста по post_id
  @comments = @db.execute 'SELECT * FROM comments WHERE post_id = ? ORDER BY id', [post_id]
    
  if post_content.length <= 0 then #если переменная post_content пустая, то
      #@error присваивается сообщение об ошибке и возвращается представление /comments
		  (erb @error = 'Type comment' and return erb :comments) 
    redirect to ('/comment/' + post_id) #redirect на эту же страницу
  end
  
  #сохранение переменных в таблицу comments
  @db.execute 'INSERT INTO
    comments (post_id, content, created_date)
      values (?, ?, datetime() )', [post_id, post_content] 
  erb :comments
  redirect to ('/comment/' + post_id)
end
