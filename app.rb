require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable :sessions

get('/') do 
    @username = session[:username]
    @id = session[:id]
    slim(:home)
end

get('/register') do
    slim(:register)
end

get('/showlogin') do
    slim(:login)
end

post('/login') do
    username = params[:username]
    password = params[:password].to_s
    db = SQLite3::Database.new("db/dungeans_database.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM users WHERE username = ?", username).first
    if result != nil
        digest_password = result["password"]
        id = result["id"]

        if BCrypt::Password.new(digest_password) == password 
            session[:id] = id
            session[:username] = username
            session[:admin] = result["admin"]
        
            redirect('/')
        else
            # tror jag borde göra detta anourlunda
            "Incorrect password"
        end
    else
        "A user with the name '#{username}' does not exist"
    end
end

post('/users/new') do
    username = params[:username].to_s
    password = params[:password].to_s
    password_confirm = params[:password_confirm].to_s

    if password == password_confirm
        password_digest = BCrypt::Password.create(password) 
        db = SQLite3::Database.new("db/dungeans_database.db")
        db.execute("INSERT INTO users (username, password, admin) VALUES (?,?,?)", username, password_digest, 0)

        redirect('/showlogin')
    else
        "Confirmed password didn't match try again"
    end
end

get('/characters') do 
    db = SQLite3::Database.new("db/dungeans_database.db")
    db.results_as_hash = true
    if session[:admin] == 1
        result = db.execute("SELECT * FROM characters")
    else
        result = db.execute("SELECT * FROM characters WHERE user_id = ?", session[:id])
    end
    slim(:"characters/index",locals:{characters:result})
end

get('/characters/new') do
    if session[:id] != nil
        db = SQLite3::Database.new("db/dungeans_database.db")
        db.results_as_hash = true
        @result = db.execute("SELECT * FROM class")
        p @result
        slim(:'characters/new')
    else
        "you have to be logged in, in order to create a character"
    end
end

post('/characters') do 
    name = params[:name]
    character_class = params[:character_class]
    race = params[:race]
    db = SQLite3::Database.new("db/dungeans_database.db")
    db.execute("INSERT INTO characters (name, class, race, user_id) VALUES (?,?,?,?)", name, character_class, race, session[:id])
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
    result2 = db.execute("SELECT * FROM class")
    slim(:'/characters/edit', locals:{result:result, result2:result2})
end

post('/characters/:id/update') do
    id = params[:id].to_i
    name = params[:name]
    user_id = params[:user_id].to_i
    character_class = params[:character_class]
    race = params[:race]
    db = SQLite3::Database.new("db/dungeans_database.db")
    db.execute("UPDATE characters SET name=?,user_id=?,class=?,race=? WHERE id = ?", name,user_id,id,character_class,race) 
    redirect('/characters')
end

get('/characters/:id') do
    id = params[:id].to_i
    db = SQLite3::Database.new("db/dungeans_database.db")
    db.results_as_hash = true
    info = db.execute("SELECT * FROM characters WHERE id = ?",id).first
    slim(:"characters/show",locals:{info:info})
end

