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

def get_headers(status, headers, body)
  app = Shelf::Builder.app do
    use Shelf::ContentLength
    run ->(_) { [status, headers, body] }
  end

  _, headers, = app.call(REQUEST_METHOD => 'GET', PATH_INFO => '/')

  headers
end

assert 'ContentLength', 'simple body' do
  headers = get_headers(200, {}, ['abc'])

  assert_include headers, CONTENT_LENGTH
  assert_equal 3, headers[CONTENT_LENGTH].to_i
end

assert 'ContentLength', 'multi body' do
  headers = get_headers(200, {}, %w[a b c])

  assert_include headers, CONTENT_LENGTH
  assert_equal 3, headers[CONTENT_LENGTH].to_i
end

assert 'ContentLength', 'already set' do
  headers = get_headers(200, { CONTENT_LENGTH => 1 }, ['Hello Shelf!'])

  assert_include headers, Shelf::CONTENT_LENGTH
  assert_equal 1, headers[Shelf::CONTENT_LENGTH].to_i
end

assert 'ContentLength', 'STATUS_WITH_NO_ENTITY_BODY' do
  headers = get_headers(101, {}, ['Hello Shelf!'])

  assert_not_include headers, Shelf::CONTENT_LENGTH
end
