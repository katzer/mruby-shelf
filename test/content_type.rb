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

def headers_for(status, headers = {}, body = [])
  app = Shelf::Builder.app do
    use Shelf::ContentType, 'something/else'
    run ->(_) { [status, headers, body] }
  end

  _, headers, = app.call(REQUEST_METHOD => 'GET', PATH_INFO => '/')

  headers
end

assert 'ContentType', 'not set' do
  headers = headers_for(200)

  assert_include headers, CONTENT_TYPE
  assert_equal 'something/else', headers[CONTENT_TYPE]
end

assert 'ContentType', 'already set' do
  headers = headers_for(200, CONTENT_TYPE => 'text/plain')

  assert_include headers, CONTENT_TYPE
  assert_equal 'text/plain', headers[CONTENT_TYPE]
end

assert 'ContentType', 'STATUS_WITH_NO_ENTITY_BODY' do
  assert_not_include headers_for(101), CONTENT_TYPE
end
