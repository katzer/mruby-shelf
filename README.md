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


## Usage

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


## Authors

- Sebastián Katzer, Fa. appPlant GmbH


## License

The mgem is available as open source under the terms of the [MIT License][license].

Made with :yum: from Leipzig

© 2017 [appPlant GmbH][appplant]


[rack]: https://github.com/rack/rack
[mruby]: https://github.com/mruby/mruby
[mruby-r3]: https://github.com/katzer/mruby-r3
[license]: http://opensource.org/licenses/MIT
[appplant]: www.appplant.de
