# Oober

Oober is a simplified [TAXII](https://taxiiproject.github.io/) client for extracting and exporting structured cyber threat intelligence.

Oober currently supports extracting data from [STIX](https://stixproject.github.io/)-formatted messages and exporting them via [CEF](https://protect724.hp.com/docs/DOC-1072) to a syslog receiver (and potentially ArcSight if you're into that sort of thing).

## Installation

you can install the gem and executables to your current ruby runtime with:

    $ gem install oober

If you plan on wrapping your own clients, adding extractors (it's super easy!), or starting a threat-polling repo, add the following to your 'Gemfile'

    gem 'oober'

and then

    $ bundle install

If you want to hack on oober, check the DEVELOPMENT section below

## Configuration
Oober currently is pretty configurable, but currently only supports extracting STIX messages from an http/basic_auth TAXII endpoint and transforming those into CEF-formatted syslog messages. If that's what you want to do, you're in luck.

In the config, you specify the TAXII discovery endpoint, the credentials and feed name you'd like to poll. Then you describe what items to select/iterate over out of that feed, what data elements to extract from those items, and how you'd like to store the results. Finally, you can provide the address/port of a syslog server to send your extracted messages. Sample configurations in the 'samples/' directory.

Element selection is specified in extractor_configs[]/select. This should be an XPath query of the deepest element you would like to iterate over.

Extractions are specified as XPath queries under extractor_configs[]/extractions[]. Each extraction has an "origin" XPath and a "target". Data elements are extracted from the "origin" expression and emitted as hash values under the key name specified in "target". The whole message/content block should be available from the starting path of the 'select' node.

Default hash key/values can be specified under extractor_configs[]/defaults. These defaults will be merged over in extraction, so you could potentially overwrite an extracted value if there is a key collision.

There's a logstash.conf in the samples/ directory for running a syslog receiver on localhost:1999 if you'd like to inspect things as they would be sent over the wire. If you'd like to go a little deeper into logstash specifically, there's a CEF codec available from the logstash plugins repository. A JSON/tcp exporter is also on the horizon.

## CLI Usage
The CLI will automatically load a config file from ~/.oober.json unless you specify another file with the --config option.

Command line help is documented with Thor. To access the help info:

    $ oober help <command>

To poll a feed:

    $ oober poll --config /path/to/some.json

To download raw messages (useful for developing configs):

    $ oober download --dir /path/to/output/dir

You can interactively test xpath queries against those downloaded messages with:

    $ oober xpath /path/to/some/files*xml

And for convenience purposes, there's an interactive pry console. The console will instantiate your client in the 'client' local variable.

    $ oober console

## Library Usage
Oober can be used in your code as a client library/interface.

- Oober.configure('filename.json') will instantiate a client with your extractor/exporter config
- '#get_blocks' will download message blocks
- '#extract_blocks' will extract hashes from the content blocks (but not transform them into the specified target format)
- '#transform_extracts' will pass your extracted hashes and create instances of your target format

## Development

Other extractors should be pretty easy to implement. I plan on taking a swing at IODEF at some point.

Other exporters should also be pretty easy to implement. This could be used to dump data into another webservice, database, file format, etc. JSON/tcp is probably next priority to make use of a logstash/elk stack. I think this will probably break some things at the outermost API layer, so please lock your versions while we're still in 0.X semver territory.

Work on the TAXII protocol bindings themselves will happen in the 'ruby-taxii' gem. If there's breakage for different server types, then I'll handle it over there. Oober will remain scoped to what's within the TAXII Content_Block.

## Security

Please be advised - there's nothing (currently) in the extractor framework preventing you from doing unsafe things in your xpath queries. You will be running these queries against content packages provided by third parties, some of which could be dangerous. This inherent vulnerability is also exacerbated by the fact that only HTTP/basic is currently supported in ruby-taxii, but even when that gets resolved, you're still interacting with potentially hostile content in a murky context. It is HIGHLY recommended that you lock down the system/network access environment as much as possible.

The config was intended to be used in a stateless manner, so you should be able to run from ephemeral instances just fine.

## Contributing

Unit tests and docs mostly missing. Need to try things out before I get more opinionated.

I'll take pull requests on the development branch. Otherwise, open an issue and I'll try to get to it.

Bug reports and pull requests are welcome on GitHub at https://github.com/ryanbreed/oober.
