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

# Access constants without prefix
Object.include Shelf

class RespondWith201
  def initialize(app)
    @app = app
  end

  def call(env)
    [201, @app.call(env)[1..2]]
  end
end

# Return the Shelf environment used for a request to +uri+.
#
def self.env_for(uri = '', opts = {})
  env = {}

  env[REQUEST_METHOD]   = opts[:method] ? opts[:method].to_s.upcase : GET
  env[SERVER_NAME]      = 'example.org'
  env[SERVER_PORT]      = '80'
  env[QUERY_STRING]     = ''
  env[PATH_INFO]        = uri
  env[SHELF_URL_SCHEME] = 'http'
  env[HTTPS]            = env[SHELF_URL_SCHEME] == 'https' ? 'on' : 'off'
  env[SCRIPT_NAME]      = opts[:script_name] || ''

  env
end

assert 'Shelf::Builder' do
  assert_kind_of Class, Shelf::Builder
end

assert 'Shelf::Builder#app' do
  assert_raise(RuntimeError) { Shelf::Builder.app }
  assert_raise(RuntimeError) { Shelf::Builder.app {} }
  assert_nothing_raised { Shelf::Builder.app { run -> {} } }
  assert_kind_of(Proc, Shelf::Builder.app { run -> {} })
end

assert 'Shelf::Builder#new' do
  assert_nothing_raised { Shelf::Builder.new }
  assert_nothing_raised { Shelf::Builder.new {} }
  assert_raise(LocalJumpError) { Shelf::Builder.app { return } }
  assert_nothing_raised { Shelf::Builder.new { run -> {} } }
  assert_kind_of(Shelf::Builder, Shelf::Builder.new { run -> {} })
end

assert 'Shelf::Builder DSL' do
  app = Shelf::Builder.new
  assert_true app.respond_to? :use
  assert_true app.respond_to? :map
  assert_true app.respond_to? :run
end

assert 'Shelf::Builder.run' do
  app = Shelf::Builder.new
  assert_nothing_raised { app.run -> () {} }
end

assert 'Shelf::Builder.map(str)' do
  app = Shelf::Builder.new
  assert_nothing_raised { app.map '/' }
  assert_raise(RuntimeError) { app.to_app }
end

assert 'Shelf::Builder.map(str, &b)' do
  app1 = Shelf::Builder.new
  assert_nothing_raised { app1.map('/') {} }
  assert_raise(RuntimeError) { app1.to_app }

  app2 = Shelf::Builder.new
  assert_nothing_raised { app2.map('/') { run -> {} } }
  assert_nothing_raised { app2.to_app }
end

assert 'Shelf::Builder.map', 'with custom data' do
  app = Shelf::Builder.app do
    get('/data', ['data']) { run ->(env) { [200, {}, env[SHELF_R3_DATA]] } }
  end

  assert_equal ['data'], app.call(env_for('/data'))[2]
end

assert 'Shelf::Builder.use' do
  app1 = Shelf::Builder.new
  assert_nothing_raised { app1.use RespondWith201 }
  assert_raise(RuntimeError) { app1.to_app }
  app1.run -> {}
  assert_nothing_raised { app1.to_app }
end

assert 'Shelf::Builder.call' do
  app1 = Shelf::Builder.app do
    map('/200') { run ->(_) { [200, {}, ['OK']] } }
  end

  assert_nothing_raised { app1.call(env_for('/')) }
  assert_equal 200, app1.call(env_for('/200'))[0]
  assert_equal 404, app1.call(env_for('/404'))[0]

  app2 = Shelf::Builder.app do
    use RespondWith201
    run ->(_) { [200, {}, ['OK']] }
  end

  assert_equal 201, app2.call(env_for('/'))[0]
end

assert 'Shelf::Builder.call', 'restrict request method' do
  app = Shelf::Builder.app do
    map('/any') { run ->(_) { [200, {}, ['OK']] } }
    put('/put') { run ->(_) { [200, {}, ['OK']] } }
  end

  assert_equal 200, app.call(env_for('/any', method: 'PUT'))[0]
  assert_equal 200, app.call(env_for('/any', method: 'GET'))[0]
  assert_equal 200, app.call(env_for('/put', method: 'PUT'))[0]
  assert_equal 404, app.call(env_for('/put', method: 'GET'))[0]
end

assert 'Shelf::Builder.call', 'same path, other method' do
  app = Shelf::Builder.app do
    get('/hoge') { run ->(_) { [200, {}, ['OK get']] } }
    put('/hoge') { run ->(_) { [200, {}, ['OK put']] } }
  end

  assert_equal ['OK get'], app.call(env_for('/hoge', method: 'GET'))[2]
  assert_equal ['OK put'], app.call(env_for('/hoge', method: 'PUT'))[2]
end

assert 'Shelf::Builder.call', 'with slugs' do
  app = Shelf::Builder.new do
    map('/users/{id}') do
      run ->(env) { [200, {}, [env[SHELF_REQUEST_QUERY_HASH][:id]]] }
    end
  end

  assert_equal ['1'], app.call(env_for('/users/1'))[2]
end
