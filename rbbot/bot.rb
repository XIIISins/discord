#!/usr/bin/env ruby

require 'discordrb'
require 'base64'
require 'dotenv'

Dotenv.load('config/config.rb')

bot = Discordrb::Commands::CommandBot.new(token: ENV['token'], prefix: '!',
    advanced_functionality: false)
rlimit = Discordrb::Commands::SimpleRateLimiter.new

# Message responders
bot.message(with_text: 'Ping!') do |_event|
    _event.respond 'Pong!'
end

## Put back the table
rlimit.bucket :table, delay: 5
bot.message(containing: [ENV['TABLE_FLIP1'], ENV['TABLE_FLIP2'], ENV['TABLE_FLIP3']]) do |_event|
  next if rlimit.rate_limited?(:table, event.channel)
  _event.respond ENV['TABLE_RESPONSE']
end

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

UnknownCommand = ENV['nocmdmsg']

bot.command(:diablo, description: 'Diablo builds, info and other stuff',
    usage: 'diablo <class>', min_args: 1) do |_event, *req|
    _D3_Unknown_Class = ENV['D3_Unknown']
    _D3_Class = [{ 
      optn: ["Demon Hunter", "DH", ],
      func: "Beginner = " + ENV['D3_DH_Beginner'] + 
        "\nIntermediate = " + ENV['D3_DH_Intermediate']
    },{ 
      optn: ["Monk"],
      func: "Beginner = " + ENV['D3_MK_Beginner'] +
        "\nSupport  = " + ENV['D3_MK_Support'] +
        "\nAdvanced = " + ENV['D3_MK_Advanced']
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

    if response =~ /^\s*$/ || response.to_s.empty?
      _event.respond(
        UnknownCommand + _D3_Class.map { |c| c[:optn].join(", ")}.join(", ")
      )
    else 
      _event.respond(response)
    end
end

bot.command(:destiny, description: 'Destiny2 info',
  usage: 'destiny <cmd>') do |_event, *arg|
    _D2_Args = [{
      arg: ["Power Guide", "PG"],
      func: "Power Progression guide: " + ENV['D2_GearGuide']
    }]
    
    args = arg.kind_of?(Array) ? arg.join(" ") : arg

    response = _D2_Args.map { |a| a[:func] if args.match( Regexp.new(/\s?(#{a[:arg].join("|")})\s?/i) ) }.join(" ")

    if response =~ /^\s*$/ || response.to_s.empty?
      _event.respond(
        UnknownCommand + _D2_Args.map { |a| a[:arg].join(", ")}.join(", ")
      )
    else
      _event.respond(response)
  end
end

bot.command(:bdo, description: 'Information regarding Black Desert Online',
  usage: 'bdo <command>') do |_event, *arg|
  
  args = arg.kind_of?(Array) ? arg.join(" ") : arg

  _BDO_Args = [{
    arg: ["test"],
    func: "Test string"
  }]

  response = _BDO_Args.map { |a| a[:func] if args.match( Regexp.new(/\s?(#{a[:arg].join("|")})\s?/i) ) }.join(" ")

  if response =~ /^\s*$/ || response.to_s.empty?
    _event.respond(
        UnknownCommand + _BDO_Args.map { |a| a[:arg].join(", ")}.join(", ")
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

# VoiceBOT Definition
bot.command(:connect) do |_event|
  # Determine if user is in a voice channel
  channel = _event.user.voice_channel

  next "You're not in a voice channel" unless channel
  bot.voice_connect(channel)
  "Connected to voice channel: #{channel.name}"
end

bot.command(:listmusic) do |_event|
  _musicdir = ENV['musicdir']
  # _musicdir = File.dirname(__FILE__) + "/#{ENV['musicdir']}"
  _file_list = Dir.glob("#{_musicdir}" + "/*")
  response = _file_list.kind_of?(Array) ? _file_list.join("\n ").gsub(/.*music\//, "") : _file_list

  if response =~ /^\s*$/ || response.to_s.empty?
    _event.respond("No music in " + ENV['musicdir'])
  else
    _event.respond("Music dir: " + ENV['musicdir'] + "\nMusic list:\n" + response)
  end
end

bot.command(:play) do |_event, file|
  _musicdir = File.dirname(__FILE__) + "/#{ENV['musicdir']}"
  if file.match(/^.*\.mp3/i)
    voice_bot.play_file(_musicdir + file)
    _event.respond("Playing: " + file)
  elsif file.match(/^.*\.dca/i)
    voice_bot.play_dca(_musicdir + file)
    _event.respond("Playing: " + file)
  end
end

bot.command(:toggle_music) do |_event|
  unless voice_bot.stream_time.to_s.strip.empty? 
    voice_bot.pause 
    _event.respond("Playback paused")
  end
    voice_bot.continue
    _event.respond("Playback continue")
end

bot.command(:stop) do |_event|
  voice_bot.stop_playing
  _event.respond("Playback stopped")
end

# End command definition

# Run bon
bot.run
