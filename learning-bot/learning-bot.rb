#!/usr/bin/env ruby

require 'discordrb'
require 'base64'

_token = File.read(File.dirname(__FILE__) + "/.token").gsub(/\n/,"")

bot = Discordrb::Commands::CommandBot.new(token: _token, prefix: '!') #, 
    # advanced_functionality: false)
rlimit = Discordrb::Commands::SimpleRateLimiter.new

CreatorB = 'XIIISins'

# Message responders
bot.message(with_text: 'Ping!') do |_event|
    _event.respond 'Pong!'
end

## Put back the table
rlimit.bucket :table, delay: 5
bot.message(containing: ['(╯°□°）╯︵ ┻━┻', '(ﾉಥ益ಥ）ﾉ﻿ ┻━┻', '(ノಠ益ಠ)ノ彡┻━┻']
    ) do |_event|
  next if rlimit.rate_limited?(:table, event.channel)
  _event.respond '┬─┬ノ( º _ ºノ)'
end


# Start command definition
# bot.command(:command_name, description: '<description',
#     usage: 'Useful info on how to use', min_args: 1) do |_event, var|
#     # stuff here
# end

# Echo
bot.bucket :echo, limit: 10, time_span: 60, delay: 6
bot.command(:echo, bucket: :echo, 
    rate_limit_message: 'Command called too soon, try again in %time% seconds', 
    description: 'repeat whatever u say', 
    usage: 'echo <text>', min_args: 1) do |_event, *echo|
    _event.respond(echo.join(' '))
end

# Password
bot.command(:repass, description: 'hash whatever string u pass as an argument', 
    usage: 'repass <random text>', min_args: 1) do |_event, *pass|
    pw = pass.join("").gsub(/\n/, "") + "\xFE"
    _event.respond(Base64.encode64(pw))
end

bot.command(:diablo, description: 'Diablo builds, info and other stuff',
    usage: 'diablo <class>', min_args: 1) do |_event, *req|
    # Demon Hunter
    _D3_DH_beginner_url = "http://www.diablofans.com/builds/96034-natalya-rain-of-vengeance-build"
    _D3_DH_intermediate_url = "http://www.diablofans.com/builds/96089-unhallowed-multishot-t13-and-gr85-fast"
    # Monk
    _D3_MK_beginner_url = "http://www.diablofans.com/builds/96080-uliana-simple-gr70-video-tutorial"
    _D3_MK_advanced_url = "http://www.diablofans.com/builds/96035-s12-swk-wol-solo-100-or-group"
    _D3_MK_supp_url = "http://www.diablofans.com/builds/96224-support-monk"
    
    _D3_Unknown_Class = "I don't know guides for this class, If you know a good one let " +
      CreatorB + " know."

    _D3_Class = [{ 
      optn: ["Demon Hunter", "DH", ],
      func: "Beginner = " + _D3_DH_beginner_url + 
          "\nIntermediate = " + _D3_DH_intermediate_url 
    },{ 
      optn: ["Monk"],
      func: "Beginner = " + _D3_MK_beginner_url +
          "\nSupport  = " + _D3_MK_supp_url +
          "\nAdvanced = " + _D3_MK_advanced_url
    },{ 
      optn: ["Barbarian", "barb"],
      func: _D3_Unknown_Class
    },{
      optn: ["Wizard", "wiz"],
      func: _D3_Unknown_Class
    },{ 
      optn: ["Witch Doctor", "WD"],
      func: _D3_Unknown_Class
    },{ 
      optn: ["Crusader", "crus"],
      func: _D3_Unknown_Class
    },{
      optn: ["Necromancer", "necro"],
      func: _D3_Unknown_Class  
    }]

    gclass = req.kind_of?(Array) ? req.join(" ") : req

    response = _D3_Class.map { |c| c[:func] if gclass.match( Regexp.new(/\s?(#{c[:optn].join("|")})\s?/i) ) }.join(" ")

    # if response.to_s.empty?
    # if response.match(/^[[:space:]]*$/)
    if response =~ /^\s*$/ || response.to_s.empty?
      _event.respond(
        "Could not read class, please use one of the following:\n" + 
        _D3_Class.map { |c| c[:optn].join(", ")}.join(", ")
      )
    else 
      _event.respond(response)
    end
end

bot.command(:destiny, description: 'Destiny2 info',
  usage: 'destiny <cmd>', min_args: 1) do |_event, *arg|
    _D2_GearGuide = 'http://dulfy.net/2017/11/01/destiny-2-power-progression-guide/'
    _D2_Args = [{
      arg: ["Power Guide", "PG"],
      func: "Power Progression guide: " + _D2_GearGuide
    }]
    
    args = arg.kind_of?(Array) ? arg.join(" ") : arg

    response = _D2_Args.map { |a| a[:func] if args.match( Regexp.new(/\s?(#{a[:arg].join("|")})\s?/i) ) }.join(" ")

    if response =~ /^\s*$/ || response.to_s.empty?
      _event.respond(
        "Unknown command, please use one of the following:\n" + 
        _D2_Args.map { |a| a[:arg].join(", ")}.join(", ")
      )
    else
      _event.respond(response)
  end
end

bot.command(:smoke, description: 'Send a message to take a break',
  usage: 'smoke') do |_event|
  _event.respond(
    "#{_event.user.username}" + " thinks it's time for a smoke"
  )
end

bot.command(:channels, description: 'list channels', usage: 'channels') do |_event|
  # _event.server.channels.map {
8  # }
  _event.respond(
    "#{_event.server.channels.name}"
  )
end
# End command definition

# Run bon
bot.run
