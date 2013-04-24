# encoding: utf-8

class Blog < ActiveRecord::Base

  serialize :comments # => array structure, contains hashes: {author, text, created_at}

  # validation goes here ... ^^

  def self.recent_posts(number = 5)
    Blog.last(number).reverse
  end

end
