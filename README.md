# mysportsfeeds-ruby

MySportsFeeds Ruby Gem brought to you by [@MySportsFeeds](https://twitter.com/MySportsFeeds).

Makes use of the [MySportsFeeds API](https://www.mysportsfeeds.com) - a flexible, developer-friendly Sports Data API.

Free for Non-Commercial Use.

##Install

    
    $ gem install mysportsfeeds-ruby

If you haven't signed up for API access, do so here [https://www.mysportsfeeds.com/index.php/register/](https://www.mysportsfeeds.com/index.php/register/)

##Usage

Create main MySportsFeeds object with API version as input parameter

    require "mysportsfeeds/mysportsfeeds"

    msf = MySportsFeeds.new(version="1.0", true)

Authenticate (v1.0 uses your MySportsFeeds account credentials)

    msf.authenticate("YOUR_USERNAME", "YOUR_PASSWORD")

Start making requests, specifying: league, season, feed, format, and any other applicable params for the feed

Get all NBA 2016-2017 regular season gamelogs for Stephen Curry, in JSON format

```
    data = msf.msf_get_data('nba', '2016-2017-regular', 'player_gamelogs', 'json', 'player' =>'stephen-curry')
```

Get all NFL 2015-2016 regular season seasonal stats totals for all Dallas Cowboys players, in XML format

```
    data = msf.msf_get_data('nfl', '2015-2016-regular', 'cumulative_player_stats', 'xml', 'team' => 'dallas-cowboys')
```

Get full game schedule for the MLB 2016 playoff season, in CSV format

```
    data = msf.msf_get_data('mlb', '2016-playoff', 'full_game_schedule', 'csv')
```

That's it!  Returned data is also stored locally under "results/" by default, in appropriately named files.
