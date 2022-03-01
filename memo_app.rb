# frozen_string_literal: true

require 'sinatra'
require 'date'
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
  @memos = memos.exec('SELECT * FROM memos;')
  erb :memos
end

# メモ追加
post '/memos' do
  title = params[:title]
  content = params[:content]
  memos.exec('INSERT INTO memos(title,content) VALUES ($1,$2);', [title, content])
  erb :new
  redirect '/memos'
end

# 新規メモ入力
get '/memos/new' do
  erb :new
end

# メモ表示
get '/memos/:id' do
  id = params[:id]
  memos.exec('SELECT * FROM memos WHERE id = $1;', [id]).each do |memo|
    @title = memo['title']
    @content = memo['content']
  end
  erb :show
end

# メモ編集画面を開く
get '/memos/:id/edit' do
  id = params[:id]
  memos.exec('SELECT * FROM memos WHERE id = $1;', [id]).each do |memo|
    @id = memo['id']
    @title = memo['title']
    @content = memo['content']
  end
  erb :edit
end

# メモ編集
patch '/memos/:id' do
  id = params[:id]
  title = params[:title]
  content = params[:content]
  memos.exec('UPDATE memos SET title= $1,content=$2 WHERE id = $3;', [title, content, id])
  redirect "/memos/#{params[:id]}"
end

# メモ削除
delete '/memos/:id' do
  id = params[:id]
  memos.exec('DELETE FROM memos WHERE id = $1;', [id])
  redirect '/memos'
end
