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
  # Shelf::CatchError catches all exceptions raised from the app it
  # wraps, logs them and returns 500 status code.
  class CatchError
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
      @app.call(env)
    rescue StandardError => e
      exception_string = dump_exception(e)

      write_exception_to_shelf_errors(exception_string, env)

      body = production? ? Utils::HTTP_STATUS_CODES[500] : exception_string

      [
        500,
        { CONTENT_TYPE => 'text/plain', CONTENT_LENGTH => body.bytesize.to_s },
        [body]
      ]
    end

    private

    # Dump the exception object into a multi line string with backtrace info.
    #
    # @param [ Exception ] e The exception to dump.
    #
    # @return [ String ]
    def dump_exception(e)
      string = "#{e.class}: #{e.message}\n"
      string << e.backtrace.map { |l| "\t#{l}" }.join("\n")
      string
    end

    # Write the dumped exception trace to SHELF_ERRORS if possible.
    #
    # @param [ String ] msg The message to log.
    # @param [ Hash ] env The Shelf request object.
    #
    # @return [ Void ]
    def write_exception_to_shelf_errors(msg, env)
      return unless env.include?(SHELF_ERRORS) || $stderr
      env[SHELF_ERRORS] ||= $stderr
      env[SHELF_ERRORS].puts(msg)
      env[SHELF_ERRORS].flush
    end

    # If the app is running in production mode.
    #
    # @return [ Boolean ]
    def production?
      !$DEBUG && ENV['SHELF_ENV'] == 'production'
    end
  end
end
