# frozen_string_literal: true

require 'sinatra'
require 'date'
require 'csv'
require 'sinatra/reloader' if development?
enable :method_override

set :environment, :production

helpers do
  def escape(text)
    Rack::Utils.escape_html(text)
  end
end

get '/' do
  redirect '/memos'
end

# メモ一覧表示
get '/memos' do
  @memos = Dir.glob('./memos/*')
  erb :memos
end

# メモ追加
post '/memos' do
  File.open("./memos/#{params[:title]}.csv", 'w', encoding: 'Shift_JIS:UTF-8') do |file|
    file.write(params[:content])
  end
  erb :new
  redirect '/memos'
end

# 新規メモ入力
get '/memos/new' do
  erb :new
end

# メモ表示
get '/memos/:title' do
  @memo = File.open("./memos/#{params[:title]}", encoding: 'Shift_JIS:UTF-8')
  erb :show
end

# メモ編集画面を開く
get '/memos/:title/edit' do
  @memo = File.open("./memos/#{params[:title]}", encoding: 'Shift_JIS:UTF-8')
  erb :edit
end

# メモ編集
patch '/memos/:title' do
  File.open("./memos/#{params[:title]}", 'w', encoding: 'Shift_JIS:UTF-8') do |file|
    file.write(params[:content])
  end
  redirect "/memos/#{params[:title]}"
end

# メモ削除
delete '/memos/:title' do
  File.delete("./memos/#{params[:title]}")
  redirect '/memos'
end
