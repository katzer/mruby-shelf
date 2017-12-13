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
  # Shelf::CommonLogger forwards every request to the given +app+, and
  # logs a line in the +logger+.
  #
  # If +logger+ is nil, CommonLogger will fall back +rack.errors+, which is
  # an instance of Shelf::NullLogger.
  #
  # +logger+ can be any class, including the standard library Logger, and is
  # expected to have either +write+ or +<<+ method, which accepts the
  # CommonLogger::FORMAT.
  # According to the SPEC, the error stream must also respond to +puts+
  # (which takes a single argument that responds to +to_s+), and +flush+
  # (which is called without arguments in order to make the error appear for
  # sure)
  class CommonLogger
    # Common Log Format: http://httpd.apache.org/docs/1.3/logs.html#common
    #
    #   lilith.local - - [07/Aug/2006 23:58:02 -0400] "GET / HTTP/1.1" 500 -
    #
    #   %{%s - %s [%s] "%s %s%s %s" %d %s\n} %
    CFORMAT = %(%s - %s [%s] "%s %s%s %s" %d %s %0.4f\n).freeze
    DFORMAT = '%02d/%02d/%04d:%02d:%02d:%02d %s'.freeze

    def initialize(app, logger = nil)
      @app    = app
      @logger = logger
    end

    def call(env)
      @logger ||= env[SHELF_LOGGER] || env[SHELF_ERRORS] || $stdout

      began_at             = Time.now
      status, header, body = @app.call(env)

      message = message_get(env, status, header, began_at)
      log(message)

      [status, header, body]
    end

    private

    # Logs the message and possibly writes them to stdout.
    #
    # @param [ String ] msg The message to log.
    #
    # @return [ Void ]
    def log(msg)
      @logger.write(msg) if @logger
    end

    # Extract the content-length info from the headers or returns a placeholder.
    #
    # @param [ Hash ] headers The headers from the shelf response.
    #
    # @return [ String ]
    def extract_content_length(headers)
      value = headers[CONTENT_LENGTH]
      return '-' unless value
      value.to_s == '0' ? '-' : value
    end

    # Format the date time object into a string.
    #
    # @param [ Time ] t The time object to format.
    #
    # @return [ String ]
    def format_datetime(t)
      format DFORMAT, t.day, t.mon, t.year, t.hour, t.min, t.sec, t.zone
    end

    # The message to log.
    #
    # @params [ Hash ] env The Shelf request.
    # @params [ Int ] status The statud code of the response.
    # @params [ Hash ] headers The env of the Shelf response.
    # @params [ Time ] began_at Timestamp of the received request.
    #
    # @return [ String ]
    def message_get(env, status, headers, began_at)
      now = Time.now

      format(CFORMAT,
             env['HTTP_X_FORWARDED_FOR'] || env['REMOTE_ADDR'] || '-',
             env['REMOTE_USER'] || '-',
             format_datetime(now),
             env[REQUEST_METHOD],
             env[PATH_INFO],
             env[QUERY_STRING].to_s.empty? ? '' : "?#{env[QUERY_STRING]}",
             env[HTTP_VERSION],
             status.to_s[0..3],
             extract_content_length(headers),
             now - began_at)
    end
  end
end
