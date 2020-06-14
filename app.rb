#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new "BlogTest.db"
	@db.results_as_hash = true
end

before do
	init_db
end

configure do
	init_db

	@db.execute 'create table if not exists Posts 
	(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		created_date DATE,
		username TEXT,
		content TEXT
	)'

	@db.execute 'create table if not exists Comments 
	(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		created_date DATE,
		username TEXT,
		content TEXT,
		post_id INTEGER
	)'
end

get '/' do
	@results = @db.execute 'select * from Posts order by id desc'

	erb :index
end

get '/new' do
	erb :new
end

post '/new' do
	username = params[:username]
	content = params[:content]

	if username.size <= 0
		@error = 'Укажите свое имя'
		return erb :new
	end

	if content.size <= 0
		@error = 'Напишите хоть что-нибудь'
		return erb :new
	end

	@db.execute 'insert into Posts (username, content, created_date) values ( ?, ?, datetime())', [username, content]

	erb "#{username}, ваше сообщение успешно добавлено"
end

get '/details/:post_id' do
	post_id = params[:post_id]

	results = @db.execute 'select * from Posts where id = ?', [post_id]

	@row = results[0]

	@comments = @db.execute 'select * from Comments where post_id = ? order by id', [post_id]

	erb :details
end

post '/details/:post_id' do
	post_id = params[:post_id]

	content = params[:content]

	if content == ''
		@error = 'Введите хоть что-нибудь!'
	end

	@db.execute 'insert into Comments 
	(
		content,
		created_date,
		post_id
	)
	values( ?, datetime(), ? )', [content, post_id]

	redirect to ('/details/' + post_id)
end