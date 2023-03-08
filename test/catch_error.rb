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

class StringIO
  def puts(msg)
    (@msgs ||= []) << msg
  end

  def flush; end

  def to_s
    @msgs&.join("\n")
  end

  alias inspect to_s

  def clear
    @msgs&.clear
  end
end

assert 'Shelf::CatchError' do
  pip = StringIO.new
  app = Shelf::Builder.app do
    use Shelf::CatchError
    run ->(env) { env['shelf.errors'] = pip; undef_method_call }
  end

  assert_nothing_raised do
    app.call({ 'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/' })
  end

  pip.clear

  ENV['SHELF_ENV'] = 'production'
  code, headers, body = app.call({ 'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/' })

  assert_equal 500, code
  assert_equal 'Internal Server Error', body[0]
  assert_equal 21, headers['Content-Length'].to_i

  ENV['SHELF_ENV'] = 'development'
  code, _, body = app.call({ 'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/' })

  assert_equal 500, code
  assert_include body[0], "NoMethodError: undefined method 'undef_method_call'"
end
