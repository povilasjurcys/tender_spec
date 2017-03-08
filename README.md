# What To Run

[![Join the chat at https://gitter.im/DyegoCosta/tender_spec](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/DyegoCosta/tender_spec?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

[![Build Status](https://travis-ci.org/DyegoCosta/tender_spec.svg?branch=master)](https://travis-ci.org/DyegoCosta/tender_spec)

What To Run is a lib for regression test selection for Ruby projects, use it to predict which tests you should run when you make any modification on your codebase.

This lib was inspired by [@tenderlove](https://github.com/tenderlove) [blog post](tenderlove-post). Make sure to check it out.


From the _[An Empirical Study of Regression Test Selection Techniques](rts-article)_ article:

> Regression testing is the process of validating modified software to detect whether new errors
have been introduced into previously tested code and to provide confidence that modifications
are correct. Since regression testing is an expensive process, researchers have proposed
regression test selection techniques as a way to reduce some of this expense. These techniques
attempt to reduce costs by selecting and running only a subset of the test cases in a program’s
existing test suite.

[rts-article]: https://www.cs.umd.edu/~aporter/Docs/p184-graves.pdf
[tenderlove-post]: http://tenderlovemaking.com/2015/02/13/predicting-test-failues.html

## Requirements

- Project must be inside a Git repository
- CMake to build the gem

## Installation

Add this line to your application's Gemfile:

```
gem 'tender_spec'
```

And then execute

```
$ bundle
```

Or install it yourself as:

```
$ gem install tender_spec
```

then add this to your config/database.yml file:
```
  tender_spec:
    adapter: mysql2 # can be any adapter supported by active record
    database: your_database_for_tender_spec_data
    # ...
```

then

```
rake db:setup RAILS_ENV=tender_spec`
```

and finaly

```
rails g tender_spec:install`
```

## Usage

Require it after requiring your test framework and before load your files to be tested and your test suite config:

Minitest

```
require 'tender_spec/minitest'
```

RSpec

```
require 'tender_spec/rspec'
```

Run your full tests suite with COLLECT=1 on a **clean git branch**

Minitest

```
$ COLLECT=1 bundle exec rake test
```

RSpec

```
$ COLLECT=1 bundle exec rspec
```

This will create the initial coverage information. Then make your desired modifications on your code.

Now to run the tests that could reveal faults do the following

```
$ tender_spec <framework> [options]
```

Supported frameworks are:

```
rspec
minitest
```

Options are:

```
-e, --exec EXECUTABLE            Alternate test runner executable
-h, --help                       Prints this help
```

## Contributing

Open an [issue](https://github.com/DyegoCosta/tender_spec/issues) or fork it and submit a [pull-request](https://help.github.com/articles/using-pull-requests/).

## License

What To Run is released under the [MIT License](http://www.opensource.org/licenses/MIT).
