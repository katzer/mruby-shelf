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
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require "#{MRUBY_ROOT}/lib/mruby/source"

MRuby::Gem::Specification.new('mruby-shelf') do |spec|
  spec.license = 'MIT'
  spec.authors = 'Sebastian Katzer'
  spec.summary = 'Modular webserver interface'

  spec.add_dependency 'mruby-r3',  mgem: 'mruby-r3'
  spec.add_dependency 'mruby-env', mgem: 'mruby-env'

  spec.add_test_dependency 'mruby-sprintf', core: 'mruby-sprintf'
  spec.add_test_dependency 'mruby-print',   core: 'mruby-print'
  spec.add_test_dependency 'mruby-time',    core: 'mruby-time'

  if MRuby::Source::MRUBY_VERSION >= '1.4.0'
    spec.add_test_dependency 'mruby-io',    core: 'mruby-io'
  else
    spec.add_test_dependency 'mruby-io',    mgem: 'mruby-io'
  end
end
