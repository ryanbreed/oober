# Oober

simplified TAXII client for sending CEF-formatted messages to ArcSight

## Installation


    $ git clone https://github.com/ryanbreed/oober
    $ cd oober
    $ git checkout develop
    $ bundle install --path=vendor/develop
    $ bundle exec rake build
    $ gem install pkg/oober-*gem

## Usage
sample configuration in spec/fixtures/config.json 

the sample config extracts IPv4 observables and their associated Observable guid and maps them to CEF events. at this time, i've only implemented and tried http/basic auth and STIX/Cybox content mapped to CEF events.

'feed_name' is the fully qualified name of the feed you'd like to poll. it is assumed you have pre-configured the feed to either only provide messages that have not been polled, or you are capable of processing duplicate events if that is not the case. 

'select' is an xpath expression to select specific xpath nodes inside a taxii content block

'extract_mappings' is an array of type/origin/target hashes that specifiy an extraction operation, the source data element selector, and the destination field name. stix extraction with xpath is the only thing that has been implemented so far. the 'target' field is the mapped key name the extracted value will be associated with. so far, only targeting CEF key names has been implemented. 

from your code:

    client=Oober.configure('path/to/config.json')
    client.poll_messages

from a shell:

    oober poll --config=path/to/config.json


## Development

unit tests and docs mostly missing. need to try things out before i get more opinionated.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ryanbreed/oober.

