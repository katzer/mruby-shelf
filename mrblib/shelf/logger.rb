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
  # Sets up shelf.logger to write to shelf.errors stream.
  class Logger
    # Initialized the middleware.
    #
    # @param [ Object ] The shelf app.
    # @param [ Int ] level The severity to use for the logger.
    #                      Defaults to: INFO
    #
    def initialize(app, level = ::Logger::INFO)
      @app   = app
      @level = level
    end

    # Sets up shelf.logger before each request.
    #
    def call(env)
      env[SHELF_ERRORS] ||= $stderr
      logger              = ::Logger.new(env[SHELF_ERRORS], level: @level)
      env[SHELF_LOGGER]   = logger

      @app.call(env)
    end
  end
end
