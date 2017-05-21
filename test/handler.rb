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

assert 'Shelf::Handler#register' do
  assert_nothing_raised { Shelf::Handler.register Object, Object }
  assert_nothing_raised { Shelf::Handler.register 'superfastobject', Object }
end

assert 'Shelf::Handler#get' do
  Shelf::Handler.register 'superfastobject', Object
  assert_equal Object, Shelf::Handler.get('superfastobject')
end

assert 'Shelf::Handler#default', '$SHELF_HANDLER not set' do
  ENV.delete 'SHELF_HANDLER'
  assert_equal Shelf::Handler::SimpleHttpServer, Shelf::Handler.default
end

assert 'Shelf::Handler#default', '$SHELF_HANDLER set' do
  Shelf::Handler.register 'superfastobject', Object
  ENV['SHELF_HANDLER'] = 'superfastobject'
  assert_equal Object, Shelf::Handler.default
  ENV.delete 'SHELF_HANDLER'
end
