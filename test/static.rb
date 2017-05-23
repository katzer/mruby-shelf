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

Object.include Shelf

ROOT = File.dirname(File.dirname(__FILE__))

def build_app(opts)
  Shelf::Builder.app do
    use Shelf::Static, { root: ROOT }.merge(opts)
    run ->(_) { [200, {}, ['A barebones shelf app']] }
  end
end

def env_for(path, method = 'GET')
  { 'REQUEST_METHOD' => method, 'PATH_INFO' => path }
end

def read_file(*path)
  IO.read File.join(ROOT, *path)
end

assert 'Static', 'url overriding' do
  app = build_app urls: { '/' => 'Rakefile' }
  code, headers, = app.call(env_for('/'))
  file           = read_file('Rakefile')

  assert_equal 200, code
  assert_equal file.bytesize, headers[CONTENT_LENGTH].to_i
end

assert 'Static', 'default route' do
  app            = build_app urls: [], index: 'README.md'
  code, headers, = app.call(env_for('/'))
  file           = read_file('README.md')

  assert_equal 200, code
  assert_equal file.bytesize, headers[CONTENT_LENGTH].to_i
end

assert 'Static', 'url' do
  app  = build_app urls: ['/test']
  body = app.call(env_for('/test/static.rb'))[2]
  file = read_file('test', File.basename(__FILE__))

  assert_equal file, body.join
end

assert 'Static', '404' do
  app   = build_app urls: ['/test']
  code, = app.call(env_for('/test/123.rb'))

  assert_equal 404, code
end

assert 'Static', '405' do
  app           = build_app urls: ['/test']
  code, headers = app.call(env_for('/test/123.rb', 'DELETE'))

  assert_equal 405, code
  assert_include headers, 'Allow'
  assert_include headers['Allow'], 'GET'
  assert_include headers['Allow'], 'OPTIONS'
end

assert 'Static', 'OPTIONS' do
  app                 = build_app urls: { '/' => 'Rakefile' }
  code, headers, body = app.call(env_for('/', 'OPTIONS'))

  assert_equal 200, code
  assert_equal '0', headers[CONTENT_LENGTH]
  assert_true body.empty?
end

assert 'Static', 'null byte' do
  app   = build_app urls: { '/' => "Rakefile\0" }
  code, = app.call(env_for('/'))

  assert_equal 400, code
end

assert 'Static', 'dot dot slash' do
  mruby = File.join(ROOT, 'mruby')
  app   = build_app urls: { '/' => '../mrblib/shelf.rb' }, root: mruby
  code, = app.call(env_for('/'))

  assert_equal 404, code
end
