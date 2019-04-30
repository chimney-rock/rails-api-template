# Rails API Template

> A common mistake that people make when trying to design something completely foolproof is to underestimate the ingenuity of complete fools.

<em>Douglas Adams - The Hitchhiker’s Guide to the Galaxy</em>

# Table of contents
<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Rails API Template](#rails-api-template)
- [Table of contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Usage](#usage)
    - [New Rails project](#new-rails-project)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Introduction

This is a very opinionated Rails 5.2+ API template that includes the following gems:
- [PG](http://bitbucket.org/ged/ruby-pg)
- [OJ](https://github.com/ohler55/oj)
- [bunny](http://github.com/ruby-amqp/bunny)
- [serverengine](https://github.com/fluent/serverengine)
- [google-protobuf](https://developers.google.com/protocol-buffers)
- [concurrent-ruby](https://github.com/ruby-concurrency/concurrent-ruby)
- [goldiloader](https://github.com/salsify/goldiloader)
- [bootsnap](https://github.com/Shopify/bootsnap)
- [GraphQL](https://github.com/rmosolgo/graphql-ruby)
- [rack-cors](https://github.com/cyu/rack-cors)
- [rack-attack](https://github.com/kickstarter/rack-attack)

## Usage

### New Rails project

```shell
rails new PROJECT_NAME \
  -m https://raw.githubusercontent.com/chimney-rock/rails-api-template/master/template.rb \
  -d postgresql \
  --skip-webpack-install \
  --skip-action-cable \
  --skip-sprockets \
  --skip-javascript \
  --skip-turbolinks \
  --skip-test \
  --api
```
