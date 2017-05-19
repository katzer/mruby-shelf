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

app = Shelf::Builder.app do
  run ->(_) { [200, {}, ['A barebones shelf app']] }
end

assert 'Shelf::Handler::SimpleHttpServer.run', 'without config' do
  ENV.delete 'SHELF_ENV'

  assert_equal 'server started', Shelf::Handler::SimpleHttpServer.run(app)

  Shelf::Handler::SimpleHttpServer.run(app) do |server|
    assert_kind_of SimpleHttpServer, server
    assert_kind_of Hash, server.config
    assert_equal app, server.config[:app]
    assert_include server.config, :port
    assert_include server.config, :server_ip
    assert_kind_of Integer, server.config[:port]
    assert_equal 8080, server.config[:port]
    assert_equal 'localhost', server.config[:server_ip]
  end
end

assert 'Shelf::Handler::SimpleHttpServer.run', 'with config' do
  Shelf::Handler::SimpleHttpServer.run(app, port: 80, server_ip: 'host') do |s|
    assert_equal 80, s.config[:port]
    assert_equal 'host', s.config[:server_ip]
  end
end

assert 'Shelf::Handler::SimpleHttpServer.run', 'SHELF_ENV=development' do
  ENV['SHELF_ENV'] = 'development'

  Shelf::Handler::SimpleHttpServer.run(app) do |server|
    assert_equal 'localhost', server.config[:server_ip]
  end
end

assert 'Shelf::Handler::SimpleHttpServer.run', 'SHELF_ENV=production' do
  ENV['SHELF_ENV'] = 'production'

  Shelf::Handler::SimpleHttpServer.run(app) do |server|
    assert_nil server.config[:server_ip]
  end
end
