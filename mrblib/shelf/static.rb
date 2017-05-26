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
# SOFTWARE.# MIT License

# rubocop:disable MutableConstant

module Shelf
  # The Shelf::Static middleware intercepts requests for static files
  # (javascript files, images, stylesheets, etc) based on the url prefixes or
  # route mappings passed in the options, and serves them using a Shelf::File
  # object. This allows a Shelf stack to serve both static and dynamic content.
  #
  # Examples:
  #
  # Serve all requests beginning with /media from the "media" folder located
  # in the current directory (ie media/*):
  #
  #     use Shelf::Static, :urls => ["/media"]
  #
  # Serve all requests beginning with /css or /images from the folder "public"
  # in the current directory (ie public/css/* and public/images/*):
  #
  #     use Shelf::Static, :urls => ["/css", "/images"], :root => "public"
  #
  # Serve all requests to / with "index.html" from the folder "public" in the
  # current directory (ie public/index.html):
  #
  #     use Shelf::Static, :urls => {"/" => 'index.html'}, :root => 'public'
  #
  # Serve all requests normally from the folder "public" in the current
  # directory but uses index.html as default route for "/"
  #
  #     use Shelf::Static, urls: [""], root: 'public', index: 'index.html'
  #
  class Static
    ALLOWED_VERBS = %w[GET HEAD OPTIONS]
    ALLOW_HEADER  = ALLOWED_VERBS.join(', ').freeze

    # Initializes the middleware with the shelf app and some options.
    #
    # @param [ Object ] app
    # @param [ Hash ] options
    #
    # @return [ Shelf::Static ]
    def initialize(app, options)
      @app   = app
      @urls  = options[:urls] || ['/favicon.ico']
      @index = options[:index]
      @root  = options[:root] || Dir.pwd
    end

    # Tests if the path virtually points to the index.html
    #
    # @params [ String ] The path info.
    #
    # @return [ Boolean ]
    def add_index_root?(path)
      @index && (path.empty? || path == '/')
    end

    # Tests if the path points to a file.
    #
    # @params [ String ] The path info.
    #
    # @return [ Boolean ]
    def overwrite_file_path?(path)
      @urls.is_a?(Hash) && @urls.key?(path) || add_index_root?(path)
    end

    # Tests if the path points to a file.
    #
    # @params [ String ] The path info.
    #
    # @return [ Boolean ]
    def route_file?(path)
      @urls.is_a?(Array) && @urls.any? { |url| path.index(url) == 0 }
    end

    # Tests if the path points to a file.
    #
    # @params [ String ] The path info.
    #
    # @return [ Boolean ]
    def can_serve?(path)
      route_file?(path) || overwrite_file_path?(path)
    end

    # Invoke the middleware. Returns the content of the file or any appropriate
    # return code.
    #
    # @param [ Hash ] env The Shelf request.
    #
    # @return [ Array ] The Shelf response.
    def call(env)
      return @app.call(env) unless can_serve? env[PATH_INFO]

      unless ALLOWED_VERBS.include? env[REQUEST_METHOD]
        return fail(405, 'Method Not Allowed', 'Allow' => ALLOW_HEADER)
      end

      path = get_path(env[PATH_INFO])

      return fail(400, 'Bad Request') unless Utils.valid_path?(path)
      return fail(404, "File not found: #{path}") unless can_read? path

      serving(path, env)
    end

    # Returns the content of the file or any appropriate return code.
    #
    # @param [ String ] path The absolute path to the file to serve.
    # @param [ Hash ] env The Shelf request.
    #
    # @return [ Array ] The Shelf response.
    def serving(path, env)
      if env[REQUEST_METHOD] == OPTIONS
        body    = []
        headers = { 'Allow' => ALLOW_HEADER, CONTENT_LENGTH => '0' }
      else
        body    = [read_asset(path)]
        headers = { CONTENT_TYPE   => mime_type(path),
                    CONTENT_LENGTH => body[0].bytesize.to_s }
      end

      [200, headers, body]
    end

    # Get the abolsute path to the file.
    #
    # @param [ String ] path The path info from env.
    #
    # @return [ String ]
    def get_path(path)
      if overwrite_file_path?(path)
        path = add_index_root?(path) ? (path + @index) : @urls[path]
      end
      File.join(@root, Utils.clean_path_info(path))
    end

    # Test if file specified by path exists and is readable.
    #
    # @param [ String ] path The path to the file.
    #
    # @return [ Boolean ]
    def can_read?(path)
      File.file?(path)
    rescue FileError
      false
    end

    # Read the content of the file specified by path.
    #
    # @param [ String ] path The path to the file.
    #
    # @return [ String ] nil if not found.
    def read_asset(path)
      fp = open(path, 'rb')
      fp.read
    ensure
      fp.close
    end

    # Construct a failure response by status code and body.
    #
    # @return [ Array ] Shelf response
    def fail(status, body, headers = {})
      body += "\n"

      [
        status,
        {
          CONTENT_TYPE   => 'text/plain',
          CONTENT_LENGTH => body.size.to_s,
          'X-Cascade' => 'pass'
        }.merge(headers),
        [body]
      ]
    end

    # The MIME type for the contents of the file located at @path.
    #
    # @param [ String ] path The path to the file.
    #
    # @return [ String ]
    def mime_type(path)
      Mime.mime_type(File.extname(path))
    end
  end
end
