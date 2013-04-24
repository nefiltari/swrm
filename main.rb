# Ruby Version: ruby-2.0.0-p0

# Require gems
require 'bundler'
Bundler.require :default
require "sinatra"
require 'pp'

# Require own libs
require_relative 'config'
require_relative 'rdf_setup'
require_relative 'linker'
require_relative 'access_control'
require_relative 'ressources'
require_relative 'storages'
#require_relative 'foafssl-ruby/lib/foafssl' # verbuggt

# Define Interface
module SWRM
  TS=Storage::Triplestore::File.new :filets # Vorläufig Ram Storage (später Sesame)
  DB = {}
  DB[:key_value] = Storage::KeyValue.new :key_value

  def self.init
    # TS.sparql =
    # Setup the Triplestore

    # init keyvalue store


    setup
  end

  def self.error action={}, code=0
    case code
    when 1001
      action[:error] = "Can't resolve Request!"
      action[:errorcode] = 1001
    when 1002
      action[:error] = "Insufficient Permissions!"
      action[:errorcode] = 1002
    when 1003
      action[:error] = "Not logged in!"
      action[:errorcode] = 1003
    when 1004
      action[:error] = "Invalid Uniform Ressource Locater!"
      action[:errorcode] = 1004
    when 1005
      action[:error] = "Unknown Action '#{action[:name]}'"
      action[:errorcode] = 1005
    when 1006
      action[:error] = "Invalid Request!"
      action[:errorcode] = 1006
    else
      action[:error] = "Internal Error!"
      action[:errorcode] = 1000
    end
    action[:rformat_http] = 'text/json'
    action
  end

  # Profilimport
  def self.import_profile
  end

  # Initialize
  init

  # Main Function
  def self.access action
    action = Linker.resolve action
    return action if action.member?(:error)
    pp action

    # Access Control Decision
    action = AccessControl.check action
    return action if action.member?(:error)

    action = Ressource.execute_action action
  end
end

# Wrapper für externe Schnittstelle
helpers do
  def requestet_action
    # params[:webid] for extern webids
    # Ersetzt durch WebID Authentikator und Sinatra
    action = {
      requester: RDF::URI.new("http://example.org/user/a\#me"), #WebID
      link: request.url,
      method: request.request_method.downcase,
      parameters: params
    }

    action = SWRM.access action
    headers "Content-Type" => action[:rformat_http]

    SWRM::Ressource.serialize_action action
  end
end

get("*") do
  requestet_action
end

post("*") do
  requestet_action
end

put("*") do
  requestet_action
end

delete("*") do
  requestet_action
end

# Test
#g = RDF::Graph.new
#g << [RDF::URI.new("http://example.org/a"), RDF::FOAF.knows, RDF::URI.new("http://example.org/b")]
#g << [RDF::URI.new("http://example.org/a"), RDF::FOAF.knows, RDF::URI.new("http://example.org/c")]

#require 'json'


#pp JSON.parse(SWRM::TS.serialize(g))
