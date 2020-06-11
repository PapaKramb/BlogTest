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
end

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
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