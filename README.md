# Shelf, a modular webserver interface for mruby <br> [![Build Status](https://travis-ci.org/katzer/mruby-shelf.svg?branch=master)](https://travis-ci.org/katzer/mruby-shelf) [![Build status](https://ci.appveyor.com/api/projects/status/n6wh7qwk3nuhf26e/branch/master?svg=true)](https://ci.appveyor.com/project/katzer/mruby-shelf/branch/master) [![codebeat badge](https://codebeat.co/badges/4d1589cf-53f9-48fe-a13b-c1f1106e7b70)](https://codebeat.co/projects/github-com-katzer-mruby-shelf-master)

Inspired by [Rack][rack], empowers [mruby][mruby], a work in progress!

> Rack provides a minimal, modular, and adaptable interface for developing web applications in Ruby. By wrapping HTTP requests and responses in the simplest way possible, it unifies and distills the API for web servers, web frameworks, and software in between (the so-called middleware) into a single method call.
>
> The exact details of this are described in the Rack specification, which all Rack applications should conform to.
>
> -- <cite>https://github.com/rack/rack</cite>

```ruby
Shelf::Builder.app do
  run ->(env) { [200, {}, ['A barebones shelf app']] }
end
```


## Installation

Add the line below to your `build_config.rb`:

```ruby
MRuby::Build.new do |conf|
  # ... (snip) ...
  conf.gem 'mruby-shelf'
end
```

Or add this line to your aplication's `mrbgem.rake`:

```ruby
MRuby::Gem::Specification.new('your-mrbgem') do |spec|
  # ... (snip) ...
  spec.add_dependency 'mruby-shelf'
end
```


## Builder

The Rack::Builder DSL is compatible with Shelf::Builder. Shelf uses [mruby-r3][mruby-r3] for the path dispatching to add some nice extras.

```ruby
app = Shelf::Builder.app do
  run ->(env) { [200, { 'content-type' => 'text/plain' }, ['A barebones shelf app']] }
end

app.call('REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/')
# => [200, { 'content-type' => 'text/plain' }, ['A barebones shelf app']]

app.call('REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/info')
# => [404, { 'content-type' => 'text/plain', 'X-Cascade' => 'pass' }, ['Not Found']]
```

Using middleware layers is dead simple:

```ruby
class NoContent
  def initialize(app)
    @app = app
  end

  def call(env)
    [204, @app.call(env)[1], []]
  end
end

app = Shelf::Builder.app do
  use NoContent
  run ->(env) { [200, { ... }, ['A barebones shelf app']] }
end

app.call('REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/')
# => [204, { ... }, []]
```

Mounted routes may contain slugs and can be restricted to a certain HTTP method:

```ruby
app = Shelf::Builder.app do
  map('/users/{id}', :GET) { run ->(env) { [200, { ... }, [env['shelf.request.query_hash'][:id]]] } }
end

app.call('REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/users/1')
# => [200, { ... }, ['1']]

app.call('REQUEST_METHOD' => 'PUT', 'PATH_INFO' => '/users/1')
# => [405, { ... }, ['Method Not Allowed']]
```


## Handler

The Rack::Handler class is mostly compatible with Shelf::Handler except that it takes the handler class instead of the path string.

```ruby
Shelf::Handler.register 'h2o', H2O::Shelf::Handler
```

Per default Shelf uses its built-in handler for [mruby-simplehttpserver][mruby-simplehttpserver]:

```ruby
Shelf::Handler.default
# => Shelf::Handler::SimpleHttpServer
```

Howver its possible to customize that:

```ruby
ENV['SHELF_HANDLER'] = 'h2o'
```


## Server

The Rack::Server API is mostly compatible with Shelf::Server except that there's no _config.ru_ file, built-in opt parser. Only the main options (:app, :port, :host, ...) are supported. Also note that :host and :port are written downcase!

```ruby
Shelf::Server.start(
  app: ->(e) {
    [200, { 'Content-Type' => 'text/html' }, ['hello world']]
  },
  server: 'simplehttpserver'
)
```

The default middleware stack can be extended per environment:

```ruby
Shelf::Server.middleware[:production] << MyCustomMiddleware
```

## Middleware

Shelf comes with some useful middlewares. These can be defined by app or by environment.

- ContentLength

  ```ruby
  app = Shelf::Builder.app do
    use Shelf::ContentLength
    run ->(env) { [200, {}, ['A barebones shelf app']] }
  end

  app.call('REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/')
  # => [200, { 'Content-Length' => 21 }, ['A barebones shelf app']]
  ```

- Head

  ```ruby
  app = Shelf::Builder.app do
    use Shelf::Head
    run ->(env) { [200, {}, ['A barebones shelf app']] }
  end

  app.call('REQUEST_METHOD' => 'HEAD', 'PATH_INFO' => '/')
  # => [200, { 'Content-Length' => 21 }, []]
  ```

- Static

  ```ruby
  app = Shelf::Builder.app do
    use Shelf::Static, urls: { '/' => 'index.html' }, root: 'public'
    run ->(env) { [200, {}, ['A barebones shelf app']] }
  end

  app.call('REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/')
  # => [200, { 'Content-Length' => xxx, 'Content-Type': 'text/html; charset=utf-8' }, ['<html>...</html>']]
  ```

  - See [here][static] for more samples.


## Development

Clone the repo:
    
    $ git clone https://github.com/katzer/mruby-shelf.git && cd mruby-shelf/

Compile the source:

    $ rake compile

Run the tests:

    $ rake test


## Authors

- Sebastián Katzer, Fa. appPlant GmbH


## License

The mgem is available as open source under the terms of the [MIT License][license].

Made with :yum: from Leipzig

© 2017 [appPlant GmbH][appplant]


[rack]: https://github.com/rack/rack
[mruby]: https://github.com/mruby/mruby
[mruby-r3]: https://github.com/katzer/mruby-r3
[mruby-simplehttpserver]: https://github.com/matsumotory/mruby-simplehttpserver
[static]: mrblib/shelf/static.rb#L31
[license]: http://opensource.org/licenses/MIT
[appplant]: www.appplant.de
