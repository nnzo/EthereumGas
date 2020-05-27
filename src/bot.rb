require 'telegram/bot'
require 'json'
require 'yaml'
require 'httparty'


def getApi(key)
  response = HTTParty.get('https://www.etherchain.org/api/gasPriceOracle')
  json = JSON.parse(response.body)
  sv1 = json[key]
  return sv1
end

telegramtoken, apikey = YAML.load(File.read("config.yaml"))

#response = $conn.get('fast')
#puts response.body.to_json
#obj = JSON.parse(response.body.to_json)
#sv1 = obj['fast']
#puts sv1

def cGetGas(userid, bot)
  bot.api.send_message(chat_id: userid, text: "Fast transaction price: #{getApi('fast')}\nSafe Low: #{getApi('safeLow')}")
end

isCalled = 0 # Never used before
Thread.new do
  while true do
    puts Time.now
    sleep 300 # Every 10 seconds, run the script again
    if isCalled == 0 # Check if it's been called in the last minute
      if getApi('safeLow').to_i <= 10 # Is safeLow lower than 10?
        $bott.api.send_message(chat_id: '-1001233948122', text: "Ethereum Gas is < 10 Gwei, start your miners!")
        isCalled = 1 # Now say that we have called it
        sleep 3600 # Next time we run the script will be in an hour
        isCalled = 0 # Now tell the script text time it runs to execute everything
      end
    end
  end
end

Telegram::Bot::Client.run(telegramtoken) do |bot|
  $bott = bot
  bot.listen do |message|
    case message.text
    when '/start'
      bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}")
    when '/getgas'
      cGetGas(message.chat.id, bot)
    when "/getgas@EthereumGasBot"
      cGetGas(message.chat.id, bot)
    when "/about@EthereumGasBot"
      bot.api.send_message(chat_id: message.chat.id, text: "Check Ethereum gas price at any time. Developed by @AtomicLemon & sponsored by @FlameExchange")
    when '/about'
      bot.api.send_message(chat_id: message.chat.id, text: "Check Ethereum gas price at any time. Developed by @AtomicLemon & sponsored by @FlameExchange")
    end
  end
end