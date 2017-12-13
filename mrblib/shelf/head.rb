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

module Shelf
  # Shelf::Head returns an empty body for all HEAD requests. It leaves
  # all other requests unchanged.
  class Head
    # Initialized with Shelf app.
    #
    def initialize(app)
      @app = app
    end

    # Removes an empty body for all HEAD requests.
    #
    # @param [ Hash ] env HTTP request environment.
    #
    # @return [ Array ] HTTP response array with updated headers.
    def call(env)
      status, headers, body = @app.call(env)

      if env[REQUEST_METHOD] == HEAD
        body.close if body.respond_to?(:close)
        body = []
      end

      [status, headers, body]
    end
  end
end
