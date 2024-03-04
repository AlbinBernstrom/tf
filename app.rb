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

get('/character_creator') do 
    slim(:character_creator)
end

get('/character/new') do
  slim(:"character/new")
end