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
  # Parse the query and put the params into the shelf.request.query_hash.
  class QueryParser
    def initialize(app)
      @app = app
    end

    def call(env)
      parse_query(env) if env[QUERY_STRING]
      @app.call(env)
    end

    private

    def parse_query(env)
      params = env[SHELF_REQUEST_QUERY_HASH] ||= {}

      env[QUERY_STRING].split('&').each do |p|
        next if p.empty?
        k, v = p.split('=', 2)

        case (item = params[k])
        when Array then item << v
        when nil   then params[k] = v
        else            params[k] = [item, v]
        end
      end
    end
  end
end
