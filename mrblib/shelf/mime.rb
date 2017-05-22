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

# rubocop:disable MutableConstant

module Shelf
  module Mime
    # Returns String with mime type if found, otherwise use +fallback+.
    # +ext+ should be filename extension in the '.ext' format that
    #       File.extname(file) returns.
    # +fallback+ may be any object
    #
    # Also see the documentation for MIME_TYPES
    #
    # Usage:
    #     Shelf::Mime.mime_type('.foo')
    def mime_type(ext, fallback = 'application/octet-stream')
      MIME_TYPES[ext.to_s.downcase] || fallback
    end

    module_function :mime_type

    MIME_TYPES = {
      '.txt'   => 'text/plain; charset=utf-8',
      '.html'  => 'text/html; charset=utf-8',
      '.css'   => 'text/css; charset=utf-8',
      '.js'    => 'appplication/js',
      '.json'  => 'appplication/json',
      '.xml'   => 'appplication/xml',
      '.gif'   => 'image/gif',
      '.jpeg'  => 'image/jpeg',
      '.png'   => 'image/png',
      '.tiff'  => 'image/tiff',
      '.svg'   => 'image/svg+xml',
      '.eot'   => 'application/vnd.ms-fontobject',
      '.woff'  => 'application/font-woff',
      '.woff2' => 'application/font-woff2'
    }
  end
end
