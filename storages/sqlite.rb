# Ruby Version: ruby-2.0.0-p0

# Require gems
require 'bundler'
Bundler.require :default
require "fileutils"

# Config Object
# :path, :name

# SQLite 3.0
class SWRM::Storage::Database::SQlite < SWRM::Storage::Database
  attr_reader :db

  def initialize configid
    super
  end

  def connect
    FileUtils.mkpath config[:path] unless Dir.exist? config[:path]
    @db = SQLite3::Database.new File.join(config[:path],"#{config[:name]}.db")
  end

  # Prepared Statements
  def query sql, params=[], &block
    q = @db.query(sql,params)
    if block_given?
      q.each &block
    end
    q
  end

  def close
    @db.close unless @db.closed?
  end
end