# Ruby Version: ruby-2.0.0-p0

# Require gems
require 'bundler'
Bundler.require :default
require 'rdf/ntriples'

module SWRM
  class Storage::Triplestore::File < Storage::Triplestore
    def connect
      super
      FileUtils.mkpath(::File.dirname(config[:repo])) unless Dir.exist?(::File.dirname(config[:repo]))
      unless ::File.exist?(config[:repo])
        f = ::File.new(config[:repo],  "w+")
        f.close
      end
      @repo.load(config[:repo])
    end
  end
end