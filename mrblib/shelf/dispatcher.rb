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

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

module Shelf
  # Shelf::Dispatcher takes a hash mapping urls or paths to apps, and
  # dispatches accordingly.
  class Dispatcher
    # Takes a hash mapping urls or paths to apps, and dispatches accordingly.
    #
    # @param [ Hash ] map
    #
    # @return [ Shelf::Dispatcher ]
    def initialize(map = {})
      remap(map)
    end

    # Parses the url map to find a matching app to call. Returns status code 404
    # if the request method does not match or 405 if the request method does not
    # match.
    #
    # @param [ Hash ] env The request env map.
    #
    # @return [ Void ]
    def call(env)
      path   = env[PATH_INFO]
      method = R3.method_code_for(env[REQUEST_METHOD])

      params, (app, data) = @tree.match(path)

      return path_not_found     unless params
      return method_not_allowed if @tree.mismatch? path, method

      store_query_hash_into_env(params, env)
      env[SHELF_R3_DATA] = data if data

      app.call(env)
    end

    private

    # Build R3::Tree based on the specified URL map.
    #
    # @param [ Hash ] map
    #
    # @return [ Void ]
    def remap(map)
      @tree.free if @tree
      @tree = R3::Tree.new(map.size)

      map.each do |method_and_route, app|
        method, route, data = method_and_route

        raise ArgumentError, 'path need to start with /' unless route[0] == '/'

        @tree.add(route, method, [app, data])
      end

      @tree.compile
    end

    # Save the parsed params from R3 into SHELF_REQUEST_QUERY_HASH.
    #
    # @param [ Hash ] hsh
    # @param [ Hash ] env
    #
    # @return [ Void ]
    def store_query_hash_into_env(hsh, env)
      if env.include? SHELF_REQUEST_QUERY_HASH
        env[SHELF_REQUEST_QUERY_HASH] = env[SHELF_REQUEST_QUERY_HASH].merge(hsh)
      else
        env[SHELF_REQUEST_QUERY_HASH] = hsh
      end
    end

    # Default response if path could not be resolved.
    #
    # @return [ Array ]
    def path_not_found
      [
        404,
        { CONTENT_TYPE => 'text/plain', 'X-Cascade' => 'pass' },
        ["#{Utils::HTTP_STATUS_CODES[404]}\n"]
      ]
    end

    # Default response if method does not match.
    #
    # @return [ Array ]
    def method_not_allowed
      [
        405,
        { CONTENT_TYPE => 'text/plain', 'X-Cascade' => 'pass' },
        ["#{Utils::HTTP_STATUS_CODES[405]}\n"]
      ]
    end
  end
end
