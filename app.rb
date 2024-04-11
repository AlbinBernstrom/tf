require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable :sessions

get('/') do 
    slim(:home)
end

get('/register') do
    slim(:register)
end

get('/login') do
    slim(:login)
end

get('/characters') do 
    db = SQLite3::Database.new("db/dungeans_database.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM characters")
    p result
    slim(:"characters/index",locals:{characters:result})

end

get('/characters/new') do
  slim(:"characters/new")
end

post('/characters/new') do 
    name = params[:name]
    user_id = params[:user_id].to_i
    p "Vi fick in datan #{name} #{user_id}"
    db = SQLite3::Database.new("db/dungeans_database.db")
    db.execute("INSERT INTO characters (name, user_id) VALUES (?,?)", name, user_id)
    redirect('/characters')
end

post('/characters/:id/delete') do
    id = params[:id].to_i
    db = SQLite3::Database.new("db/dungeans_database.db")
    db.execute("DELETE FROM characters WHERE id = ?",id)
    redirect('/characters')
end

get('/characters/:id/edit') do
    id = params[:id].to_i
    db = SQLite3::Database.new("db/dungeans_database.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM characters WHERE id = ?",id).first
    p "hej"
    slim(:'/characters/edit', locals:{result:result})
end

post('/characters/:id/update') do
    id = params[:id].to_i
    name = params[:name]
    user_id = params[:user_id].to_i
    db = SQLite3::Database.new("db/dungeans_database.db")
    db.execute("UPDATE characters SET name=?,user_id=? WHERE id = ?", name,user_id,id) 
    redirect('/characters')
end

