require 'fileutils'
require 'json'
require 'base64'
require 'net/http'
require 'uri'

module Mysportsfeeds
    module Api
        # API class for dealing with v1.0 of the API
        class API_v1_0

            # Constructor
            def initialize(verbose, store_type=nil, store_location=nil)
                @base_uri = URI("https://www.mysportsfeeds.com/api/feed/pull")
                @headers = {
                    # 'Accept-Encoding': 'gzip',
                    'User-Agent': "MySportsFeeds Ruby/#{MySportsFeeds::Ruby::VERSION} (#{RUBY_PLATFORM})"
                }

                @verbose = verbose
                @store_type = store_type
                @store_location = store_location

                @valid_feeds = [
                    'current_season',
                    'cumulative_player_stats',
                    'full_game_schedule',
                    'daily_game_schedule',
                    'daily_player_stats',
                    'game_playbyplay',
                    'game_boxscore',
                    'scoreboard',
                    'player_gamelogs',
                    'team_gamelogs',
                    'roster_players',
                    'game_startinglineup',
                    'active_players',
                    'player_injuries',
                    'latest_updates',
                    'daily_dfs',
                    'overall_team_standings',
                    'conference_team_standings',
                    'division_team_standings',
                    'playoff_team_standings'
                ]
            end

            # Verify a feed
            def __verify_feed_name(feed)
                is_valid = false

                for value in self.valid_feeds
                    if value == feed
                        is_valid = true
                        break
                    end
                end

                return is_valid
            end

            # Verify output format
            def __verify_format(format)
                is_valid = true

                if format != 'json' and format != 'xml' and format != 'csv'
                    is_valid = false
                end

                return is_valid
            end

            # Feed URL (with only a league specified)
            def __league_only_url(league, feed, output_format, params)
                return "#{@base_url}/#{league}/#{feed}.#{output_format}"
            end

            # Feed URL (with league + season specified)
            def __league_and_season_url(league, season, feed, output_format, params)
                return "#{@base_url}/#{league}/#{season}/#{feed}.#{output_format}"
            end

            # Generate the appropriate filename for a feed request
            def __make_output_filename(league, season, feed, output_format, params)
                filename = "#{feed}-#{league.downcase}-#{season}"

                if params.key?("gameid")
                    filename << "-" << params["gameid"]
                end

                if params.key?("fordate")
                    filename << "-" << params["fordate"]
                end

                filename << "." << output_format

                return filename
            end

            # Save a feed response based on the store_type
            def __save_feed(response, league, season, feed, output_format, params)
                # Save to memory regardless of selected method
                if output_format == "json"
                    store_output = response.json()
                elsif output_format == "xml"
                    store_output = response.text
                elsif output_format == "csv"
                    #store_output = response.content.split('\n')
                    store_output = response.content.decode('utf-8')
                    store_output = csv.reader(store_output.splitlines(), delimiter=',')
                    store_output = list(store_output)
                end

                if @store_type == "file":
                    if !File.exist?(@store_location)
                        FileUtils::mkdir_p @store_location
                    end

                    filename = __make_output_filename(league, season, feed, output_format, params)

                    outfile = File.open(@store_location + filename, "w")
                        if output_format == "json"  # This is JSON
                            outfile.write(store_output)

                        elsif output_format == "xml"  # This is xml
                            outfile.write(store_output)

                        elsif output_format == "csv"  # This is csv
                            outfile.write(store_output)

                        else
                            raise Exception.new("Could not interpret feed output format")
                        end
                    end
                end
            end

            # Indicate this version does support BASIC auth
            def supports_basic_auth()
                return true
            end

            # Establish BASIC auth credentials
            def set_auth_credentials(username, password)
                @auth = {"username": username, "password": password}
            end

            # Request data (and store it if applicable)
            def get_data(*kwargs)
                if !@auth:
                    raise Exception.new("You must authenticate() before making requests.")
                end

                # establish defaults for all variables
                league = ""
                season = ""
                feed = ""
                output_format = ""
                params = {}

                # iterate over args and assign vars
                kwargs.each do [key, value]
                    if key == 'league'
                        league = value
                    elsif key == 'season'
                        season = value
                    elsif key == 'feed'
                        feed = value
                    elsif key == 'format'
                        output_format = value
                    else
                        params[key] = value
                    end
                end

                # add force=false parameter (helps prevent unnecessary bandwidth use)
                if !params.key?("force")
                    params['force'] = 'false'
                end

                if __verify_feed_name(feed) == false
                    raise Exception.new("Unknown feed '" + feed + "'.")
                end

                if __verify_format(output_format) == false
                    raise Exception.new("Unsupported format '" + output_format + "'.")
                end

                if feed == 'current_season'
                    url = __league_only_url(league, feed, output_format, params)
                else
                    url = __league_and_season_url(league, season, feed, output_format, params)
                end

                if @verbose
                    puts "Making API request to '#{url}'."
                    puts "  with headers:"
                    puts @headers
                    puts " and params:"
                    puts params
                end

                http = Net::HTTP.new(@base_uri.host, @base_uri.port)
                http.use_ssl = true
                http.verify_mode = OpenSSL::SSL::VERIFY_NONE
                request = Net::HTTP::Get.new(url)
                request.basic_auth(@auth["username"], @auth["password"])

                r = http.request(request)

                if r.code == 200
                    if @store_type != nil
                        __save_feed(r.body, league, season, feed, output_format, params)
                    end

                    if output_format == "json"
                        data = JSON.parse(r.body)
                    elsif output_format == "xml":
                        data = r.body
                    else
                        data = r.body
                    end

                elsif r.code == 304
                    if @verbose
                        puts "Data hasn't changed since last call"
                    end

                    filename = __make_output_filename(league, season, feed, output_format, params)

                    f = File.open(@store_location + filename, "r")
                        if output_format == "json"
                            data = JSON.parse(f)
                        elsif output_format == "xml"
                            data = f
                        else
                            data = f
                        end
                    end

                else
                    puts "API call failed with error: #{r.code}"
                end

                return data
            end
        end
    end
end
