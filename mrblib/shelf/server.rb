# MIT License
#
# Copyright (c) Sebastian Katzer 2017
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

module Shelf
  class Server
    # Start a new shelf server.
    #
    # Providing an options hash will prevent ARGV parsing and will not include
    # any default options.
    #
    # This method can be used to very easily launch a CGI application, for
    # example:
    #
    #  Shelf::Server.start(
    #    :app => lambda do |e|
    #      [200, {'Content-Type' => 'text/html'}, ['hello world']]
    #    end,
    #    :server => 'cgi'
    #  )
    #
    # Further options available here are documented on Shelf::Server#initialize
    def self.start(options = nil, &blk)
      new(options).start(&blk)
    end

    # Default middleware layer used for logging.
    #
    # @return [ Class ]
    def self.logging_middleware
      ->(server) { CommonLogger unless server.options[:quiet] }
    end

    # List of middleware per environment.
    #
    # @return [ Hash<String, Array>]
    def self.middleware
      @m ||= begin
        m = Hash.new { |h, k| h[k] = [] }
        m['production']  = [logging_middleware, ContentLength, CatchError]
        m['development'] = [logging_middleware, ContentLength, CatchError]
        m
      end
    end

    # Options may include:
    # * :app
    #     a shelf application to run (overrides :config)
    # * :environment
    #     this selects the middleware that will be wrapped around
    #     your application.
    # * :server
    #     choose a specific Shelf::Handler, e.g. simplehttpserver
    # * :host
    #     the host address to bind to (used by supporting Shelf::Handler)
    # * :port
    #     the port to bind to (used by supporting Shelf::Handler)
    # * :debug
    #     turn on debug output ($DEBUG = true)
    def initialize(options = {})
      @options = default_options.merge(options)
      @app     = @options.delete(:app)
    end

    attr_accessor :options, :app

    # See Shelf::Server::middleware
    def middleware
      self.class.middleware
    end

    # The server class to use for.
    #
    # @return [ Class ]
    def server
      @_server ||= Shelf::Handler.get(options[:server])
      @_server   = Shelf::Handler.default unless @_server
      @_server
    end

    # Run the server.
    #
    # @param [ Proc ] blk Optional code block to pass to the server.
    #
    # @return [ Void ]
    def start(&blk)
      $DEBUG = true if options[:debug]

      trap(:INT) { shutdown } if respond_to? :trap

      @app = @app.to_app if @app.is_a? Builder
      options.delete(:app)

      server.run(build_app(app), options, &blk)
    end

    # Tries to shutdown the running server.
    #
    # @param [ Int ] exit_code Defaults to: 0
    #
    # @return [ Void ]
    def shutdown(exit_code = 0)
      if server.respond_to?(:shutdown)
        server.shutdown
      elsif respond_to? :exit
        exit(exit_code)
      end
    end

    private

    # Default environment, port and host to use as server config.
    #
    # @return [ Hash ]
    def default_options
      environment  = ENV['SHELF_ENV'] || 'development'
      default_host = environment == 'development' ? 'localhost' : '0.0.0.0'

      { environment: environment, port: 9292, host: default_host }
    end

    # Build the app by prepending all middlewares.
    #
    # @param [ Proc] app The Shelf app to build.
    #
    # @return [ Proc ]
    def build_app(app)
      middleware[options[:environment]].reverse.each do |middleware|
        middleware = middleware.call(self) if middleware.respond_to?(:call)

        next unless middleware

        klass, *args = middleware
        app          = klass.new(app, *args)
      end

      app
    end
  end
end
