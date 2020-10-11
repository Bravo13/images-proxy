# images proxy

## Requirments
To run this app you need perl itself and some additional perl-packages. Here is a list of required packages:
* [Dancer2](https://metacpan.org/pod/Dancer2)
* [Dancer2::Plugin::Database](https://metacpan.org/pod/Dancer2::Plugin::Database)
* [DBD::SQLite](https://metacpan.org/pod/DBD::SQLite) (or any other DB package)
* [Dancer2::Plugin::REST](https://metacpan.org/pod/Dancer2::Plugin::REST)
* [Dancer2::Plugin::Cache::CHI](https://metacpan.org/pod/Dancer2::Plugin::Cache::CHI)
* [LWP::UserAgent](https://metacpan.org/pod/LWP::UserAgent)
* [Syntax::Keyword::Try](Syntax::Keyword::Try)

## Config template
You need to create config.yml and fill it with some data. Example is below
```yml
appname: "Images Proxy"
charset: "UTF-8"

serializer: "JSON"

plugins:
  Database:
    driver: "SQLite"
    database: 'app.sqlite'
  "Cache::CHI":
    driver: "Memory"
    global: 1

logger: Console

api_key: "<PUT_YOUR_TOKEN_HERE>"

engines:
  logger:
    Console:
      log_level: core

```

## Running
Just run `perl ./app.pl` and app is ready to reciewe requests on http://localhost:3000.
