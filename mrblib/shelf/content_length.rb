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
  # Sets the Content-Length header on responses with fixed-length bodies.
  class ContentLength
    # Initialized with Shelf app.
    #
    def initialize(app)
      @app = app
    end

    # Calculate CONTENT_LENGTH if desired and not yet done.
    #
    # @param [ Hash ] env HTTP request environment.
    #
    # @return [ Array ] HTTP response array with updated headers.
    def call(env)
      status, headers, body = @app.call(env)

      if    !Utils::STATUS_WITH_NO_ENTITY_BODY.include?(status.to_i) \
         && !headers[CONTENT_LENGTH] \
         && !headers[TRANSFER_ENCODING] \
         && body.respond_to?(:to_a)

        length = body.reduce(0) { |len, part| len + part.bytesize }

        body.close if body.respond_to?(:close)

        headers[CONTENT_LENGTH] = length.to_s
      end

      [status, headers, body]
    end
  end
end
