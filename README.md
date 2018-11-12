# NestedLookup [![Build Status](https://travis-ci.com/rameshrvr/nested_lookup.svg?branch=master)](https://travis-ci.com/rameshrvr/nested_lookup) [![Coverage Status](https://codecov.io/gh/rameshrvr/nested_lookup/badge.svg?branch=master)](https://codecov.io/gh/rameshrvr/nested_lookup?branch=master) [![Gem Version](https://badge.fury.io/rb/nested_lookup.svg)](https://badge.fury.io/rb/nested_lookup)

Ruby library which enables key/value lookup, update, delete on deeply nested documents (Arrays and Hashes)

Features: (document might be Array of Hashes/Hash, Arrays/nested Arrays/nested Hashes etc)
1. (nested_lookup) key lookups on deeply nested document.
2. (get_all_keys) fetching all keys from a nested document.
3. (get_occurrence_of_key/get_occurrence_of_value) get the number of occurrences of a key/value from a nested document
4. (nested_get) Get a value in a nested document using its key
5. (nested_update) Update a value in a nested document using its key
6. (nested_delete) Delete a key->value pair in nested document using its key

Documents may be built out of nested Hashes and/or Arrays.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nested_lookup'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nested_lookup

## Usage

### quick tutorial

```ruby
Rameshs-MacBook-Pro:nested_lookup rameshrv$ irb
irb(main):001:0> require 'nested_lookup'
=> true
irb(main):003:0> sample_data = {
irb(main):004:1*   "hardware_details": {
irb(main):005:2*     "model_name": 'MacBook Pro',
irb(main):006:2*     "processor_details": [
irb(main):007:3*       {
irb(main):008:4*         "processor_name": 'Intel Core i7',
irb(main):009:4*         "processor_speed": '2.7 GHz',
irb(main):010:4*         "core_details": {
irb(main):011:5*           "total_numberof_cores": '4',
irb(main):012:5*           "l2_cache(per_core)": '256 KB'
irb(main):013:5>         }
irb(main):014:4>       }
irb(main):015:3>     ],
irb(main):016:2*     "os_details": {
irb(main):017:3*       "product_version": '10.13.6',
irb(main):018:3*       "build_version": '17G65'
irb(main):019:3>     },
irb(main):020:2*     "memory": '16 GB'
irb(main):021:2>   },
irb(main):022:1*   "dup_hardware_details": {
irb(main):023:2*     "model_name": 'MacBook Pro - 1',
irb(main):024:2*     "os_details": {
irb(main):025:3*       "product_version": '10.14.0',
irb(main):026:3*       "build_version": '17G65'
irb(main):027:3>     },
irb(main):028:2*   }
irb(main):029:1> }
=> {:hardware_details=>{:model_name=>"MacBook Pro", :processor_details=>[{:processor_name=>"Intel Core i7", :processor_speed=>"2.7 GHz", :core_details=>{:total_numberof_cores=>"4", :"l2_cache(per_core)"=>"256 KB"}}], :os_details=>{:product_version=>"10.13.6", :build_version=>"17G65"}, :memory=>"16 GB"}, :dup_hardware_details=>{:model_name=>"MacBook Pro - 1", :os_details=>{:product_version=>"10.14.0", :build_version=>"17G65"}}}
irb(main):030:0> 
irb(main):032:0> 
# Search for key 'product_version'
irb(main):033:0* sample_data.nested_lookup('product_version')
=> ["10.13.6", "10.14.0"]
# Fetch all keys from the document
irb(main):034:0> sample_data.get_all_keys
=> ["hardware_details", "model_name", "processor_details", "processor_name", "processor_speed", "core_details", "total_numberof_cores", "l2_cache(per_core)", "os_details", "product_version", "build_version", "memory", "dup_hardware_details", "model_name", "os_details", "product_version", "build_version"]
# Get occurrence of key 'model_name' (present in both 'hardware_details', 'dup_hardware_details')
irb(main):035:0> sample_data.get_occurrence_of_key('model_name')
=> 2
# Get occurrence of value 'memory' (It is actually a key, should return 0)
irb(main):036:0> sample_data.get_occurrence_of_value('memory')
=> 0
# Get occurrence of value 'Intel Core i7'
irb(main):037:0> sample_data.get_occurrence_of_value('Intel Core i7')
=> 1
# Get value for the key 'memory', 'l2_cache(per_core)'
irb(main):032:0* sample_data.nested_get('memory')
=> "16 GB"
irb(main):033:0> sample_data.nested_get('l2_cache(per_core)')
=> "256 KB"
# Delete a key in nested document (key -> 'hardware_details')
irb(main):034:0> sample_data.nested_delete('hardware_details')
=> {:dup_hardware_details=>{:model_name=>"MacBook Pro - 1", :os_details=>{:product_version=>"10.14.0", :build_version=>"17G65"}}}
# Update a key in nested document (key -> 'hardware_details')
irb(main):035:0> sample_data.nested_update(key: 'hardware_details', value: 'Test')
=> {:hardware_details=>"Test", :dup_hardware_details=>{:model_name=>"MacBook Pro - 1", :os_details=>{:product_version=>"10.14.0", :build_version=>"17G65"}}}
irb(main):036:0>
```

### longer tutorial

You may control the nested_lookup method's behavior by passing some optional arguments.

1. wild (defaults to `False`):

 - if `wild` is `True`, treat the given `key` as a case insensitive
 substring when performing lookups.

2. with_keys (defaults to `False`):

 - if `with_keys` is `True`, return a Hash of all matched keys
  and an Array of values.

For example, given the following document:

```ruby
sample_data = {
  "hardware_details": {
    "model_name": 'MacBook Pro',
    "processor_details": [
      {
        "processor_name": 'Intel Core i7',
        "processor_speed": '2.7 GHz',
        "core_details": {
          "total_numberof_cores": '4',
          "l2_cache(per_core)": '256 KB'
        }
      }
    ],
    "os_details": {
      "product_version": '10.13.6',
      "build_version": '17G65'
    },
    "memory": '16 GB'
  }
}
```

We could act `wild` and find all the version like this:

```ruby
irb(main):069:0* sample_data.nested_lookup('version', wild: true)
=> ["10.13.6", "17G65"]
irb(main):072:0>
```

Additionally, if you also needed the matched key names, you could do this:

```ruby
irb(main):071:0* sample_data.nested_lookup('version', wild: true, with_keys: true)
=> {"product_version"=>["10.13.6"], "build_version"=>["17G65"]}
irb(main):073:0* sample_data.nested_lookup('product_version', with_keys: true)
=> {"product_version"=>["10.13.6"]}
irb(main):074:0> 
```

To get a list of every nested key in a document, run this:

```ruby
irb(main):060:0* require 'nested_lookup'
=> false
irb(main):061:0> include NestedLookup
=> Object
irb(main):062:0> sample_data.get_all_keys
=> ["hardware_details", "model_name", "processor_details", "processor_name", "processor_speed", "core_details", "total_numberof_cores", "l2_cache(per_core)", "os_details", "product_version", "build_version", "memory"]
irb(main):063:0> 
```

To get the number of occurrence of the given key/value

```ruby
irb(main):060:0* require 'nested_lookup'
=> false
irb(main):061:0> include NestedLookup
=> Object
irb(main):064:0* sample_data.get_occurrence_of_key('processor_speed')
=> 1
irb(main):065:0> sample_data.get_occurrence_of_value('256 KB')
=> 1
irb(main):072:0>
```

To Get / Delete / Update a key->value pair in a nested document

```ruby
irb(main):001:0> require 'nested_lookup'
=> true
irb(main):066:0* sample_data.nested_get('os_details')
=> {:product_version=>"10.13.6", :build_version=>"17G65"}
irb(main):067:0> sample_data.nested_get('memory')
=> "16 GB"
irb(main):068:0> sample_data.nested_delete('processor_details')
=> {:hardware_details=>{:model_name=>"MacBook Pro", :os_details=>{:product_version=>"10.13.6", :build_version=>"17G65"}, :memory=>"16 GB"}}
irb(main):069:0> sample_data.nested_update(key: 'processor_details', value: 'Test')
=> {:hardware_details=>{:model_name=>"MacBook Pro", :processor_details=>"Test", :os_details=>{:product_version=>"10.13.6", :build_version=>"17G65"}, :memory=>"16 GB"}}
irb(main):070:0>
```

Delete key->value pair (Normal and bang menthod)

```ruby
# Normal method (Returns a document that includes everything but the given key)
irb(main):068:0> sample_data.nested_delete('processor_details')
=> {:hardware_details=>{:model_name=>"MacBook Pro", :os_details=>{:product_version=>"10.13.6", :build_version=>"17G65"}, :memory=>"16 GB"}}
irb(main):071:0* sample_data
=> {:hardware_details=>{:model_name=>"MacBook Pro", :processor_details=>[{:processor_name=>"Intel Core i7", :processor_speed=>"2.7 GHz", :core_details=>{:total_numberof_cores=>"4", :"l2_cache(per_core)"=>"256 KB"}}], :os_details=>{:product_version=>"10.13.6", :build_version=>"17G65"}, :memory=>"16 GB"}}
# Bang method (Replaces the document without the given key)
irb(main):074:0* sample_data.nested_delete!('processor_details')
=> {:hardware_details=>{:model_name=>"MacBook Pro", :os_details=>{:product_version=>"10.13.6", :build_version=>"17G65"}, :memory=>"16 GB"}}
irb(main):075:0> sample_data
=> {:hardware_details=>{:model_name=>"MacBook Pro", :os_details=>{:product_version=>"10.13.6", :build_version=>"17G65"}, :memory=>"16 GB"}}
```

Update value for the given key (Normal and bang method)

```ruby
# Normal method (Returns a document that has updated key, value pair)
irb(main):109:0* sample_data.nested_update(key: 'processor_details', value: 'Test')
=> {:hardware_details=>{:model_name=>"MacBook Pro", :processor_details=>"Test", :os_details=>{:product_version=>"10.13.6", :build_version=>"17G65"}, :memory=>"16 GB"}, :dup_hardware_details=>{:model_name=>"MacBook Pro - 1", :os_details=>{:product_version=>"10.14.0", :build_version=>"17G65"}}}
irb(main):110:0> sample_data
=> {:hardware_details=>{:model_name=>"MacBook Pro", :processor_details=>[{:processor_name=>"Intel Core i7", :processor_speed=>"2.7 GHz", :core_details=>{:total_numberof_cores=>"4", :"l2_cache(per_core)"=>"256 KB"}}], :os_details=>{:product_version=>"10.13.6", :build_version=>"17G65"}, :memory=>"16 GB"}, :dup_hardware_details=>{:model_name=>"MacBook Pro - 1", :os_details=>{:product_version=>"10.14.0", :build_version=>"17G65"}}}
# Replaces the document with the updated key, value pair
irb(main):114:0* sample_data.nested_update!(key: 'processor_details', value: 'Test')
=> {:hardware_details=>{:model_name=>"MacBook Pro", :processor_details=>"Test", :os_details=>{:product_version=>"10.13.6", :build_version=>"17G65"}, :memory=>"16 GB"}, :dup_hardware_details=>{:model_name=>"MacBook Pro - 1", :os_details=>{:product_version=>"10.14.0", :build_version=>"17G65"}}}
irb(main):115:0> sample_data
=> {:hardware_details=>{:model_name=>"MacBook Pro", :processor_details=>"Test", :os_details=>{:product_version=>"10.13.6", :build_version=>"17G65"}, :memory=>"16 GB"}, :dup_hardware_details=>{:model_name=>"MacBook Pro - 1", :os_details=>{:product_version=>"10.14.0", :build_version=>"17G65"}}}

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rameshrvr/nested_lookup. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the NestedLookup project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/rameshrvr/nested_lookup/blob/master/CODE_OF_CONDUCT.md).
