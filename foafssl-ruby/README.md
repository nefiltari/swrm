# foafssl-ruby
## A FOAF+SSL implementation for Ruby and Rack

FOAFSSL implements the FOAF+SSL authentication mechanism as a
middleware application for Rack.

In short, the client provides a classical __X509 Certificate__
containing a [WebID](http://esw.w3.org/WebID) in the _subjectAltName_.
The library will extract that information from the given certificate
and read the [FOAF](http://www.foaf-project.org/) file at this URL.
If it mentions the correct __RSAPublicKey__ for the certificate, then
the authentication is successful.

-> http://esw.w3.org/Foaf%2Bssl
-> http://foafssl.org/

__FOAFSSL__ can be used directly as a Rake middleware, in which case
it will save the authentication result into the rack.session.

-> [FOAFSSL::Authentication](http://github.com/hellekin/foafssl-ruby/blob/master/lib/foafssl/authentication.rb)

It also comes as a Warden Strategy.

-> [FOAFSSL::Warden](http://github.com/hellekin/foafssl-ruby/blob/master/lib/foafssl/warden.rb)

### License

`foafssl-ruby` is free software released under the GNU Affero Public License. (See [COPYING](/hellekin/foafssl-ruby/blob/master/COPYING).)

## Requirements

FOAFSSL depends on OpenSSL, RDF and RDF::Raptor.

On Debian:

    sudo apt-get install libopenssl-ruby1.8
    sudo gem install rdf rdf/raptor

Run `rake` to find out if you miss something.

### For Testing and Development

Tests are using rspec:

    sudo gem install rspec

The code is available on Github:
http://github.com/hellekin/foafssl-ruby

## Web Server Configuration

### Apache2

You need to setup Apache2 to server SSL requests.  There are plenty of
docs about it. Here is the relevant bits for FOAF+SSL:

    SSLEngine             on
    ...

    <Location /signon>
      SSLRequireSSL
      SSLVerifyClient optional_no_ca
      # SSLVerifyClient require
      SSLVerifyDepth 1
      SSLOptions +ExportCertData +StdEnvVars 
      # SSLOptions +StrictRequire
    </Location>

#### Some explanations:

The /signon Location directive explicitely requires a client
certificate (`SSLRequireSSL`).

The Issuer verification is minimal (optional_no_ca means it won't
complain if the CA isn't trusted) because we don't care.  We only want
to match the RSAPublicKey with the WebID, i.e. demonstrate that the
user connecting to our service is the one publishing the FOAF file.

`SSLVerifyDepth 1` tells Apache to limit the CA certificate chain to 1
(instead of default 10) so we speed up the process __as we don't care
about the CA trust mechanism__. Finally, `SSLOption +ExportCertData`
tells Apache to fill the `SSL_CLIENT_CERT` with the file (in PEM format)
it received from the client.  

This last point is important, because FOAFSSL uses two headers:
`HTTP_X_FORWARDED_PROTO` and `HTTP_SSL_CLIENT_CERT`.  The HTTP_ prefix is
added by Rack, so Apache2 has to set `X_FORWARDED_PROTO` and
`SSL_CLIENT_CERT`:

    RequestHeader set X_FORWARDED_PROTO   'https'
    RequestHeader set SSL_CLIENT_CERT     %{SSL_CLIENT_CERT}e

Note the 'e' at the end of %{SSL_CLIENT_CERT}e: it tells Apache2 to
get the variable from its environment.  It won't work if you remove
it! [details?]

### Nginx

TODO

### Other

You can generate the Yard documentation by running rake doc:simple.

It requires yard: `sudo gem install yard`

If you're a developer, you might want to run `rake doc:all` instead.

## Example

Here is a Rails application.  You configured it to use FOAFSSL Rack middleware:

    Rails.config.middleware.use FOAFSSL::Rack

In your ApplicationController, create a before_filter:

    before_filter :foafssl_authentication

    def foafssl_authentication
      if session[:foafssl_authenticated]
        webid = session[:foafssl_authenticated].first
        user  = User.find_by_webid(webid)
        if user
          user.authenticate!
          current_user = user
        end
      end
    end

If __FOAFSSL__ performed authentication, it set
`session[:foafssl_authenticated]` to either __false__ (authentication
failed) or an __Array__ containing the WebID (an URI), the public
exponent of the RSAPublicKey from the authenticated SSL Certificate,
and the modulus of that key.

With that, you can retry verification (if you don't trust the FOAFSSL
library) but otherwise, only the WebID is useful: due to the nature of
FOAF+SSL, you can't expect the WebID to match the key you previously
had for it.  The user could be on a different browser, or have changed
his keys and present a new certificate.

What *you* know is that whoever presents herself as "WebID" does have
the private key to the SSL Certificate it presents, and have control
on what is published at the WebID.  Nothing more.
