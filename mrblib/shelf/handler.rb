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
  # *Handlers* connect web servers with Shelf.
  #
  # Shelf includes Handlers for SimpleHttpServer.
  #
  # Handlers usually are activated by calling <tt>MyHandler.run(myapp)</tt>.
  # A second optional hash can be passed to include server-specific
  # configuration.
  module Handler
    # Handle for given shorthand name.
    #
    # @param [ String ] server
    #
    # @return [ Class ]
    def self.get(server)
      @handlers[server]
    end

    # Default Server handler to use.
    #
    # @return [ Class ]
    def self.default
      get ENV.fetch('SHELF_HANDLER', 'simplehttpserver')
    end

    # Register a handler class via a shorthand hand.
    # The handler class needs to respond to `run`.
    #
    # @param [ String ] server
    # @param [ Class ] klass
    #
    # @return [ Void ]
    def self.register(server, klass)
      (@handlers ||= {})[server.to_s] = klass
    end
  end
end
