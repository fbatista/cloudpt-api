Cloudpt::API - Cloudpt Ruby API client
=========

A Ruby client for the Cloudpt REST API.

Goal:

To deliver a more Rubyesque experience when using the Cloudpt API.

Current state:

First release, whole API covered.

Important!!!
------------

From version 0.2.0, Cloudpt::API::File#delete and Cloudpt::API::Dir#delete *are gone*!!

The reason is that it's based on Hashie::Mash and was screwing Hash#delete.

It is replaced with Cloudpt::API::File#destroy and Cloudpt::API::Dir#destroy.

Installation
------------

Cloudpt::API is available on RubyGems, so:

```
gem install Cloudpt-api
```

Or in your Gemfile:

```ruby
gem "Cloudpt-api"
```

Configuration
-------------

In order to use this client, you need to have an app created on https://www.Cloudpt.com/developers/apps.

Once you have it, put this configuration somewhere in your code, before you start working with the client.

```ruby
Cloudpt::API::Config.app_key    = YOUR_APP_TOKEN
Cloudpt::API::Config.app_secret = YOUR_APP_SECRET
Cloudpt::API::Config.mode       = "sandbox" # if you have a single-directory app or "Cloudpt" if it has access to the whole Cloudpt
```

Cloudpt::API::Client
--------------------

The client is the base for all communication with the API and wraps around almost all calls
available in the API.

In order to create a Cloudpt::API::Client object, you need to have the configuration set up for OAuth.
Second thing you need is to have the user authorize your app using OAuth. Here's a short intro
on how to do this:

```ruby
consumer = Cloudpt::API::OAuth.consumer(:authorize)
request_token = consumer.get_request_token
request_token.authorize_url(:oauth_callback => 'http://yoursite.com/callback')
# Here the user goes to Cloudpt, authorizes the app and is redirected
# The oauth_token will be available in the params
request_token.get_access_token(:oauth_verifier => oauth_token)
```

Now that you have the oauth token and secret, you can create a new instance of the Cloudpt::API::Client, like this:

```ruby
client = Cloudpt::API::Client.new :token => token, :secret => secret
```

Rake-based authorization
------------------------

Cloudpt::API supplies you with a helper rake which will authorize a single client. This is useful for development and testing.

In order to have this rake available, put this on your Rakefile:

```ruby
require "Cloudpt-api/tasks"
Cloudpt::API::Tasks.install
```

You will notice that you have a new rake task - Cloudpt:authorize

When you call this Rake task, it will ask you to provide the consumer key and secret. Afterwards it will present you with an authorize url on Cloudpt.

Simply go to that url, authorize the app, then press enter in the console.

The rake task will output valid ruby code which you can use to create a client.

What differs this from the Cloudpt Ruby SDK?
--------------------------------------------

A few things:

* It's using the ruby oauth gem, instead of reinventing the wheel and implementing OAuth communication
* It treats files and directories as Ruby objects with appropriate classes, on which you can perform operations

Consider the following example which takes all files with names like 'test.txt' and copies them with a suffix '.old'

This is how it would look using the SDK:

```ruby
# Because you need the session with the right access token, you need to create one instance per user
@session = CloudptSession.new(APP_TOKEN, APP_SECRET)
@session.set_access_token(ACCESS_TOKEN, ACCESS_SECRET)
@client = CloudptClient.new(@session, :app_folder)
# The result is a hash, so we need to call a method on the client, supplying the right key from the hash
@client.search('/', 'test.txt').each do |hash|
  @client.file_copy(hash['path'], hash['path'] + ".old")
end
```

With Cloudpt::API, you can clean it up, first you put the app token and secret in a config or initializer file:

```ruby
Cloudpt::API::Config.app_key    = APP_TOKEN
Cloudpt::API::Config.app_secret = APP_SECRET
```

And when you want to use it, just create a new client object with a specific access token and secret:

```ruby
# The app token and secret are read from config, that's all you need to have a client ready for one user
@client = Cloudpt::API::Client.new(:token  => ACCESS_TOKEN, :secret => ACCESS_SECRET)
# The file is a Cloudpt::API::File object, so you can call methods on it!
@client.search('test.txt').each do |file|
  file.copy(file.path + ".old2")
end
```

What differs this from the Cloudpt gem?
--------------------------------------

Cloudpt::API does not extend the Ruby primitives, like the Cloudpt gem:

https://github.com/RISCfuture/Cloudpt/tree/master/lib/Cloudpt/extensions

Cloudpt::API::Client methods
----------------------------

### Cloudpt::API::Client#account

Returns a simple object with information about the account:

```ruby
client.account # => #<Cloudpt::API::Object>
```

For more info, see [https://www.Cloudpt.com/developers/reference/api#account-info](https://www.Cloudpt.com/developers/reference/api#account-info)

### Cloudpt::API::Client#find

When provided a path, returns a single file or directory

```ruby
client.find 'file.txt' # => #<Cloudpt::API::File>
```

### Cloudpt::API::Client#ls

When provided a path, returns a list of files or directories within that path

By default it's the root path:

```ruby
client.ls # => [#<Cloudpt::API::File>, #<Cloudpt::API::Dir>]
```

But you can provide your own path:

```ruby
client.ls 'somedir' # => [#<Cloudpt::API::File>, #<Cloudpt::API::Dir>]
```

### Cloudpt::API::Client#mkdir

Creates a new directory and returns a Cloudpt::API::Dir object

```ruby
client.mkdir 'new_dir' # => #<Cloudpt::API::Dir>
```

### Cloudpt::API::Client#upload

Stores a file with a provided body under a provided name and returns a Cloudpt::API::File object

```ruby
client.upload 'file.txt', 'file body' # => #<Cloudpt::API::File>
```

### Cloudpt::API::Client#download

Downloads a file with a provided name and returns it's content

```ruby
client.download 'file.txt' # => 'file body'
```

### Cloudpt::API::Client#search

When provided a pattern, returns a list of files or directories within that path

By default it searches the root path:

```ruby
client.search 'pattern' # => [#<Cloudpt::API::File>, #<Cloudpt::API::Dir>]
```

However, you can specify your own path:

```ruby
client.search 'pattern', :path => 'somedir' # => [#<Cloudpt::API::File>, #<Cloudpt::API::Dir>]
```

### Cloudpt::API::Client#delta

Returns a cursor and a list of files that have changed since the cursor was generated.

```ruby
delta = client.delta 'abc123'
delta.cursor # => 'def456'
delta.entries # => [#<Cloudpt::API::File>, #<Cloudpt::API::Dir>]
```

When called without a cursor, it returns all the files.

```ruby
delta = client.delta 'abc123'
delta.cursor # => 'abc123'
delta.entries # => [#<Cloudpt::API::File>, #<Cloudpt::API::Dir>]
```

Cloudpt::API::File and Cloudpt::API::Dir methods
----------------------------

These methods are shared by Cloudpt::API::File and Cloudpt::API::Dir

### Cloudpt::API::File#copy | Cloudpt::API::Dir#copy

Copies a file/directory to a new specified filename

```ruby
file.copy 'newfilename.txt' # => #<Cloudpt::API::File>
```

### Cloudpt::API::File#move | Cloudpt::API::Dir#move

Moves a file/directory to a new specified filename

```ruby
file.move 'newfilename.txt' # => #<Cloudpt::API::File>
```

### Cloudpt::API::File#destroy | Cloudpt::API::Dir#destroy

Deletes a file/directory

```ruby
file.destroy 'newfilename.txt' # => #<Cloudpt::API::File>
```


Cloudpt::API::File methods
----------------------------

### Cloudpt::API::File#revisions

Returns an Array of Cloudpt::API::File objects with appropriate rev attribute

For more info, see [https://www.Cloudpt.com/developers/reference/api#revisions](https://www.Cloudpt.com/developers/reference/api#revisions)

### Cloudpt::API::File#restore

Restores a file to a specific revision

For more info, see [https://www.Cloudpt.com/developers/reference/api#restore](https://www.Cloudpt.com/developers/reference/api#restore)

### Cloudpt::API::File#share_url

Returns the link to a file page in Cloudpt

For more info, see [https://www.Cloudpt.com/developers/reference/api#shares](https://www.Cloudpt.com/developers/reference/api#shares)

### Cloudpt::API::File#direct_url

Returns the link to a file in Cloudpt

For more info, see [https://www.Cloudpt.com/developers/reference/api#media](https://www.Cloudpt.com/developers/reference/api#media)

### Cloudpt::API::File#thumbnail

Returns the thumbnail for an image

For more info, see [https://www.Cloudpt.com/developers/reference/api#thumbnail](https://www.Cloudpt.com/developers/reference/api#thumbnail)

### Cloudpt::API::File#download

Downloads a file and returns it's content

```ruby
file.download # => 'file body'
```

Cloudpt::API::Dir methods
----------------------------

### Cloudpt::API::Dir#ls

Returns a list of files or directorys within that directory

```ruby
dir.ls # => [#<Cloudpt::API::File>, #<Cloudpt::API::Dir>]
```

Testing
---------

In order to run tests, you need to have an application created and authorized. Put all tokens in spec/connection.yml and you're good to go.

Check out spec/connection.sample.yml for an example.

Copyright
---------

Copyright (c) 2011 Marcin Bunsch, Future Simple Inc. See LICENSE for details.
