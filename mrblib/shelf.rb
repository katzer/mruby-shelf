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
  HTTP_HOST         = 'HTTP_HOST'.freeze
  HTTP_VERSION      = 'HTTP_VERSION'.freeze
  HTTPS             = 'HTTPS'.freeze
  PATH_INFO         = 'PATH_INFO'.freeze
  REQUEST_METHOD    = 'REQUEST_METHOD'.freeze
  REQUEST_PATH      = 'REQUEST_PATH'.freeze
  SCRIPT_NAME       = 'SCRIPT_NAME'.freeze
  QUERY_STRING      = 'QUERY_STRING'.freeze
  SERVER_PROTOCOL   = 'SERVER_PROTOCOL'.freeze
  SERVER_NAME       = 'SERVER_NAME'.freeze
  SERVER_ADDR       = 'SERVER_ADDR'.freeze
  SERVER_PORT       = 'SERVER_PORT'.freeze
  CACHE_CONTROL     = 'Cache-Control'.freeze
  CONTENT_LENGTH    = 'Content-Length'.freeze
  CONTENT_TYPE      = 'Content-Type'.freeze
  SET_COOKIE        = 'Set-Cookie'.freeze
  TRANSFER_ENCODING = 'Transfer-Encoding'.freeze
  HTTP_COOKIE       = 'HTTP_COOKIE'.freeze
  ETAG              = 'ETag'.freeze

  # HTTP method verbs
  GET     = 'GET'.freeze
  POST    = 'POST'.freeze
  PUT     = 'PUT'.freeze
  PATCH   = 'PATCH'.freeze
  DELETE  = 'DELETE'.freeze
  HEAD    = 'HEAD'.freeze
  OPTIONS = 'OPTIONS'.freeze
  LINK    = 'LINK'.freeze
  UNLINK  = 'UNLINK'.freeze
  TRACE   = 'TRACE'.freeze

  # Shelf environment variables
  SHELF_ERRORS                         = 'shelf.errors'.freeze
  SHELF_LOGGER                         = 'shelf.logger'.freeze
  SHELF_REQUEST_FORM_HASH              = 'shelf.request.form_hash'.freeze
  SHELF_REQUEST_FORM_VARS              = 'shelf.request.form_vars'.freeze
  SHELF_REQUEST_QUERY_HASH             = 'shelf.request.query_hash'.freeze
  SHELF_URL_SCHEME                     = 'shelf.url_scheme'.freeze
end
