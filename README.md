# datApi

This template-tool provide runners to consume data from any API, parse it with your rules and store where you want.

## Installation
Clone this repository to directory you want.
Then run `bundle install`.

## Getting started
Create jobs in __jobs__ dir in _.yml_.

After all run
`whenever --update-crontab`
to write your jobs to crontab.
Also you can simply run rake tasks in Jenknins or anywhere you want.

## Jobs explanation
You can simply configure your tasks with _.yml_.
```yml
name: jira_projects

shedule: hourly

source:
  request:
    url: https://localhost/rest/api/2/project
    method: GET
    headers:
      Content-Type: application/json

  result_parser:
    root_element: '.'

    mapping:
      primary_key: &primary_key id
      keys:
        - key
        - name

work:
  - example_worker

save:
  name: my_mongo
  db: JIRA
  table: projects
  primary_key: *primary_key
```
###### shedule:
by default supports 2 values - `daily` or `hourly`, but you can [customize it](#automation).

###### source:
Requests support any method, but payload do not realized.
In `headers` key you can pass any headers in key-value style.
###### result_parser:
`root_element` is optional key. Example when you need to customize your root
```json
{
  "status": "success",
  "count": "1000",
  "issues": [ 
    { 
      "id": "1",
      "type": "record",
      "fields":
        { "name": "first" }
    },
    {
      "id": "2",
      "type": "record",
      "fields":
        { "name": "second" }
    },
    ...
  ]
}
```
In this approach you must set it to
```yml
  root_element: issues
```
If your JSON return array, you can set `root_element` to `'.'` or even delete this key.

`primary_key` is the key you need to check, if record already exists in your database.

`keys` works with 2 options:
* if data you need at the top level of JSON and you dont need to change his name - just pass __string__
* if data you need is nested in low level, you need to set his name as key and pass a string-path in JSON with `.` as delimeter. For JSON example above your job will looks like
```yml
mapping:
  primary_key: &primary_key id
  keys:
    - type
    - name: fields.name

```
After this you will get your parsed data in Ruby like
```ruby
[{ 'id' => '1', 'type' => 'record', 'name' => 'first'}, ...]
```
###### work:
Calling selected classes from __lib/workers__ on each record you get after parsing.
So you can do your math, enrich you data or anything you want.
When you writing your workers*.rb, be sure you are using keys you are mapped before.
###### save:
Settings for database name and collection.
Also in your __config/database.yml__ stored global settings for DB connections.


## DB connectors

In your job file
```yml
save:
  name: my_mongo
  db: JIRA
  table: bugs
  primary_key: *primary_key
```
`name` key is link to a __config/database.yml__

```yml
my_mongo:
  connector: mongo
  url: localhost:27017
```
Also, `connector` key will looks for ` MongoConnector` class in __lib/db_connectors__

If you want any additional connector, for example - _elasticsearch_, you must create __lib/db_connectors/elasticsearch_connector.rb__ and implement simple interface
```ruby
class ElasticsearchConnector
  def initialize(params, config)
    @url = config['url']
    @db = params['db']
    @table = params['table']

    @primary_key = params['primary_key']
  end

  def save(data)
  end

end
```
The main idea to keep data in your store always synced with API provider, so your `save` method must save new records or update if record already exists with provided `primary_key`.

## <a name="automation"></a>Automation
Default rake tasks have 2 options - daily and hourly. But you can add any custom. For example in `Rakefile`:
```ruby
task :custom do
  ruby 'main.rb', 'custom'
end
```
and in your jobs set config
```yml
shedule: custom
```
After all settings run
`whenever --update-crontab`
to write your jobs to crontab.
Also you can simply run rake tasks in Jenknins or anywhere you want.

## TODO ideas
* passing params in jobs config and process it with ERB
* realize worker that can process data before saving
* tool can make SQL request (not sure it necessary )
* simple web-view to check jobs statuses and logs
