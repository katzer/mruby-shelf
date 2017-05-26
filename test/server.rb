# MIT License
#
# Copyright (c) Sebastian Katzer 2017
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the 'Software'), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Mock for SimpleHttpServer
class SimpleHttpServer
  def initialize(config)
    @config = config
  end

  attr_reader :config

  def run
    'server started'
  end
end

assert 'Shelf::Server::middleware' do
  assert_true Shelf::Server.respond_to? :middleware
  assert_kind_of Hash, Shelf::Server.middleware

  assert_include Shelf::Server.middleware, 'production'
  assert_include Shelf::Server.middleware, 'development'

  assert_kind_of Array, Shelf::Server.middleware['xyz']

  Shelf::Server.middleware['test'] << Object
  assert_include Shelf::Server.middleware['test'], Object
end

assert 'Shelf::Server#initialize', 'without options' do
  assert_nothing_raised { Shelf::Server.new }

  server = Shelf::Server.new

  assert_kind_of Hash, server.options
  assert_include server.options, :port
  assert_include server.options, :host
  assert_include server.options, :environment
  assert_nil server.app
end

assert 'Shelf::Server#initialize', 'SHELF_ENV' do
  assert_nothing_raised { Shelf::Server.new }

  ENV.delete 'SHELF_ENV'
  server = Shelf::Server.new
  assert_equal 'development', server.options[:environment]
  assert_equal 'localhost',   server.options[:host]

  ENV['SHELF_ENV'] = 'production'
  server = Shelf::Server.new
  assert_equal 'production', server.options[:environment]
  assert_equal '0.0.0.0', server.options[:host]

  ENV.delete 'SHELF_ENV'
end

assert 'Shelf::Server#initialize', 'with options' do
  server = Shelf::Server.new app: 'myapp', port: 0, host: 'myhost'

  assert_kind_of Hash, server.options
  assert_equal 'myapp', server.app
  assert_equal 'myhost', server.options[:host]
  assert_equal 0, server.options[:port]
end

assert 'Shelf::Server#middleware' do
  assert_equal Shelf::Server.middleware, Shelf::Server.new.middleware
end

assert 'Shelf::Server::middleware', 'development' do
  assert_include Shelf::Server.middleware['development'], Shelf::ContentLength
end

assert 'Shelf::Server::middleware', 'production' do
  assert_include Shelf::Server.middleware['production'], Shelf::ContentLength
end

assert 'Shelf::Server#server' do
  ENV.delete 'SHELF_HANDLER'
  assert_equal Shelf::Handler::SimpleHttpServer, Shelf::Server.new.server

  Shelf::Handler.register 'superfastobject', Object
  assert_equal Object, Shelf::Server.new(server: 'superfastobject').server
end

assert 'Shelf::Server#trap_int_signal_to_shutdown_server' do
  assert_nothing_raised do
    Shelf::Server.new.trap_int_signal_to_shutdown_server
  end
end

assert 'Shelf::Server#start' do
  block_invoked = false

  assert_equal 'server started', Shelf::Server.start(app: -> {})

  Shelf::Server.start(app: -> {}, debug: true, port: -1) do |server|
    block_invoked = true
    middleware    = Shelf::Server.middleware[server.config[:environment]]

    assert_true $DEBUG
    assert_equal(-1, server.config[:port])

    if middleware.any?
      assert_kind_of middleware.first, server.config[:app]
    else
      assert_kind_of Proc, server.config[:app]
    end
  end

  assert_true block_invoked
end
