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

class Logger
  def initialize(_, opts)
    @level = opts[:level]
  end
  attr_accessor :level
end

assert 'Shelf::Logger' do
  app = Shelf::Builder.app do
    use Shelf::Logger, 101
    run ->(env) { [200, env, ['A barebones shelf app']] }
  end

  _, headers, = app.call('REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/')

  assert_include headers, Shelf::SHELF_LOGGER
  assert_kind_of Logger, headers[Shelf::SHELF_LOGGER]
  assert_equal 101, headers[Shelf::SHELF_LOGGER].level
end
