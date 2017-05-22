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

      params, (host, app) = @tree.match(path)

      return path_not_found     unless params && server_match?(env, host)
      return method_not_allowed if @tree.mismatch? path, method

      env[SHELF_REQUEST_QUERY_HASH] = params

      app.call(env)
    end

    private

    # Build R3::Tree based on the specified URL map.
    #
    # @param [ Hash ] map
    #
    # @return [ Void ]
    def remap(map)
      @tree = R3::Tree.new(map.size)
      map.each do |method_and_route, app|
        method, route = method_and_route
        match_data    = %r{\Ahttps?://(.*?)(/.*)}.match(route)
        host, route   = match_data[0, 1] if match_data

        raise ArgumentError, 'path need to start with /' unless route[0] == '/'

        @tree.add(route, method, [host, app])
      end

      @tree.compile
    end

    # Finds out if the requesting host matches the specified host.
    #
    # @param [ Hash ] env Constains the requested host.
    # @param [ String ] host The specified host.
    #
    # @return [ Boolean ]
    def server_match?(env, host)
      horst  = env[HTTP_HOST]
      server = env[SERVER_NAME]
      port   = env[SERVER_PORT]

      is_same_server = casecmp?(horst, server) ||
                       casecmp?(horst, "#{server}:#{port}")

      casecmp?(horst, host) \
      || casecmp?(server, host) \
      || (!host && is_same_server)
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

    # Compares two string for equality.
    #
    def casecmp?(v1, v2)
      # if both nil, or they're the same string
      return true if v1 == v2

      # if either are nil... (but they're not the same)
      return false if v1.nil?
      return false if v2.nil?

      # otherwise check they're not case-insensitive the same
      v1.casecmp(v2) == 0
    end
  end
end
