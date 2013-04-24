# Ruby Version: ruby-2.0.0-p0

# Require gems
require 'bundler'
Bundler.require :default
require "fileutils"

# Storages für das Ressourcenmanagement
module SWRM
  class Storage
    attr_reader :config

    def initialize configid
      @config = Config[configid.to_sym]
      connect
    end

    def connect
    end
  end

  class Storage::Database < Storage
    def initialize
    end

    def query sql
    end
  end

  class Storage::KeyValue < Storage
    attr_reader :repo

    def connect
      @repo = Kioku.new(@config[:path])
    end
  end

  # Default Repository (Path Repositories) | URL or System path
  class Storage::Repository < Storage
    attr_reader :repo

    def connect
      super
      @repo = @config[:path]
      FileUtils.mkpath(@repo) unless Dir.exist?(@repo)
      @repo = (@repo[-1] != "/") ? "#{@repo}/" : @repo
    end

    def query id
      file = File.join @repo, id
      File.exist?(file) ? file : ""
    end
  end

  # Default Triplestore (Ram)
  class Storage::Triplestore < Storage
    attr_reader :repo
    attr_accessor :sparql

    def connect
      super
      @repo = RDF::Repository.new
      @sparql = nil
    end

    def serialize data
      return nil if data.class != RDF::Graph
      data.to_json
    end

    def unserialize data
      ret = RDF::Graph.new
      return nil if data.class != String
      RDF::JSON::Reader.new(data) do |reader|
        reader.each_statement do |s|
          ret << s
        end
      end
      ret
    end

    def query where=[], &block
      where.map! do |val|
        unless val.class == RDF::Query::Pattern
          RDF::Query::Pattern.new(val[0],val[1],val[2])
        else
          val
        end
      end

      query = nil
      solutions = if @sparql
        query = @sparql.select.where(where)
        query.solutions
      else
        RDF::Query.execute(@repo,where) { |q| query = q }
      end

      if block_given?
        solutions.each &block
      end
      query
    end
  end
end

# Include Storage Type Classes
Dir.chdir "#{File.expand_path(File.dirname(__FILE__))}/storages"
Dir.glob("*.rb") { |bib| require_relative "storages/#{File.basename(bib,".rb")}" }
