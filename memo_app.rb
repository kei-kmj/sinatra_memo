# frozen_string_literal: true

require 'sinatra'
require 'date'
require 'csv'
require 'sinatra/reloader' if development?
require 'pg'

enable :method_override

set :environment, :production

helpers do
  def escape(text)
    Rack::Utils.escape_html(text)
  end
end

memos = PG.connect(dbname: 'memodb')

get '/' do
  redirect '/memos'
end

# メモ一覧表示
get '/memos' do
  @memos = memos
  erb :memos
end

# メモ追加
post '/memos' do
  title = params[:title]
  content = params[:content]
  memos.exec("INSERT INTO memos(title,content) VALUES ($1,$2);", [title, content])
  erb :new
  redirect '/memos'
end

# 新規メモ入力
get '/memos/new' do
  erb :new
end

# メモ表示
get '/memos/:title' do
  title = params[:title]
  memos.exec("SELECT * FROM memos WHERE title = $1;", [title]).each do |memo|
    @title = memo['title']
    @content = memo['content']
  end
  erb :show
end

# メモ編集画面を開く
get '/memos/:title/edit' do
  title = params[:title]
  memos.exec("SELECT * FROM memos WHERE title = $1;", [title]).each do |memo|
    @title = memo['title']
    @content = memo['content']
  end
  erb :edit
end

# メモ編集
patch '/memos/:title' do
  title = params[:title]
  content = params[:content]
  memos.exec("UPDATE memos SET title= $1,content=$2 WHERE title = $1;", [title, content])
  redirect "/memos/#{params[:title]}"
end

# メモ削除
delete '/memos/:title' do
  title = params[:title]
  memos.exec("DELETE FROM memos WHERE title = $1;", [title])
  redirect '/memos'
end
