# encoding: utf-8

# initialize gems
require 'bundler'
Bundler.require :default

# load models
Dir['./models/**/*.rb'].each{|file| require file}

# set some parameters
set :partial_template_engine, :slim
set :database, "sqlite3:///db/data.sqlite3"

get '/' do
  ap Blog.methods
  @recent_posts = Blog.recent_posts(5)
  slim :index
end
