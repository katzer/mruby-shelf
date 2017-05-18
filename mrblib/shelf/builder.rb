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

# rubocop:disable Style/TrivialAccessors

module Shelf
  # Shelf::Builder implements a small DSL to iteratively construct Shelf
  # applications.
  #
  # Example:
  #
  #  require 'shelf/lobster'
  #  app = Shelf::Builder.new do
  #    use Shelf::CommonLogger
  #    use Shelf::ShowExceptions
  #    map "/lobster" do
  #      use Shelf::Lint
  #      run Shelf::Lobster.new
  #    end
  #  end
  #
  #  run app
  #
  # Or
  #
  #  app = Shelf::Builder.app do
  #    use Shelf::CommonLogger
  #    run lambda { |env| [200, {'Content-Type' => 'text/plain'}, ['OK']] }
  #  end
  #
  #  run app
  #
  # +use+ adds middleware to the stack, +run+ dispatches to an application.
  # You can use +map+ to construct a Shelf::URLMap in a convenient way.
  #
  class Builder
    # Evaluate the code block and return a Shelf app.
    #
    # @param [ Proc ] default_app The optional app to use.
    # @param [ Proc ] &block
    #
    # @return [ Proc ]
    def self.app(default_app = nil, &block)
      new(default_app, &block).to_app
    end

    # Create a builder instance.
    #
    # @param [ Proc ] default_app The optional app to use.
    # @param [ Proc ] &block
    #
    # @return [ Shelf::Builder ]
    def initialize(default_app = nil, &block)
      @use, @map, @run = [], nil, default_app
      instance_eval(&block) if block_given?
    end

    # Specifies middleware to use in a stack.
    #
    #   class Middleware
    #     def initialize(app)
    #       @app = app
    #     end
    #
    #     def call(env)
    #       env["shelf.some_header"] = "setting an example"
    #       @app.call(env)
    #     end
    #   end
    #
    #   use Middleware
    #   run lambda { |env| [200, { "Content-Type" => "text/plain" }, ["OK"]] }
    #
    # All requests through to this application will first be processed by the
    # middleware class.
    # The +call+ method in this example sets an additional environment key which
    # then can be referenced in the application if required.
    #
    def use(middleware, *args, &block)
      if @map
        mapping, @map = @map, nil
        @use.push ->(app) { generate_map app, mapping }
      end

      @use.push ->(app) { middleware.new(app, *args, &block) }
    end

    # Takes an argument that is an object that responds to #call and returns a
    # Shelf response.
    #
    # The simplest form of this is a lambda object:
    #
    #   run lambda { |env| [200, { "Content-Type" => "text/plain" }, ["OK"]] }
    #
    # However this could also be a class:
    #
    #   class Heartbeat
    #     def self.call(env)
    #      [200, { "Content-Type" => "text/plain" }, ["OK"]]
    #     end
    #   end
    #
    #   run Heartbeat
    #
    def run(app)
      @run = app
    end

    # Creates a route within the application.
    #
    #   Shelf::Builder.app do
    #     map '/' do
    #       run Heartbeat
    #     end
    #   end
    #
    # The +use+ method can also be used here to specify middleware to run under
    # a specific path:
    #
    #   Shelf::Builder.app do
    #     map '/' do
    #       use Middleware
    #       run Heartbeat
    #     end
    #   end
    #
    # This example includes a piece of middleware which will run before requests
    # hit +Heartbeat+.
    #
    def map(path, method = R3::ANY, &block)
      (@map ||= {})[[method, path]] = block
    end

    # Creates a GET route within the application.
    #
    def get(path, &block)
      map(path, R3::GET, &block)
    end

    # Creates a POST route within the application.
    #
    def post(path, &block)
      map(path, R3::POST, &block)
    end

    # Creates a PUT route within the application.
    #
    def put(path, &block)
      map(path, R3::PUT, &block)
    end

    # Creates a DELETE route within the application.
    #
    def delete(path, &block)
      map(path, R3::DELETE, &block)
    end

    # Transforms the builder into a shelf app.
    #
    # @return [ Proc ]
    def to_app
      app = @map ? generate_map(@run, @map) : @run
      raise 'missing run or map statement' unless app
      @use.reverse.inject(app) { |a, e| e[a] }
    end

    private

    def generate_map(default_app, mapping)
      mapped = default_app ? { '/' => default_app } : {}

      mapping.each do |r, b|
        mapped[r] = self.class.new(default_app, &b).to_app
      end

      Dispatcher.new(mapped)
    end
  end
end
