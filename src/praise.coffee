# Description:
#  素直になれないあなたに代わって賞賛の言葉を述べる
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   :good @[account] [message] -  賞賛の言葉を述べます
#   (y) @[account] [message] - 賞賛の言葉を述べます
#   +1 @[account] [message] - 賞賛の言葉を述べます
#   :+1: @[account] [message] - 賞賛の言葉を述べます
#
#   hubot who praised - 褒めた履歴(いいねログ)を見る
#
# Events:
#   praised
#     label: "praise",
#     sender: current_user,
#     receiver: user,
#     message: message
#
# Author:
#   Hgsk (@hgsk)


module.exports = (robot) ->

  robot.hear /^:good @([^ ]*)( (.*))?/i, (msg) ->
    if praiseUser(msg, robot)
      updatePraises(msg, robot)

  robot.hear /\(y\) @([^ ]*)( (.*))?/i, (msg) ->
    if praiseUser(msg, robot)
      updatePraises(msg, robot)

  robot.hear /^:+1: @([^ ]*)( (.*))?/i, (msg) ->
    if praiseUser(msg, robot)
      updatePraises(msg, robot)

  robot.hear /^\+1 @([^ ]*)( (.*))?/i, (msg) ->
    if praiseUser(msg, robot)
      updatePraises(msg, robot)

  robot.respond /who praised/i, (msg) ->
    getPraises(msg, robot)


praiseUser = (msg, robot) ->
  user = msg.match[1].replace(/@?(.*)/, '$1')
  message = if msg.match[3] then msg.match[3] else ''
  current_user = msg.message.user.name
  today = new Date().toLocaleString()

  if user == current_user
    msg.send "#{current_user}さん が自分にいいねしました"
    return false
  else
    room =  process.env.PRAISE_NOTIFY_ROOM ? msg.envelope.room

    info = {
      label: "praise",
      receiver: user,
      sender: current_user,
      message: message,
      date: today
    }

    robot.logger.info info
    robot.messageRoom room, "#{current_user}さん が #{user}さん にいいねしました."
    robot.emit "praised", info

    return true

updatePraises = (msg, robot) ->
  currentPraises = robot.brain.get('praises')
  today = new Date().toLocaleString()

  if !currentPraises || currentPraises.length == 0
    currentPraises = []

  currentPraises.push(
    {
      receiver: msg.match[1].replace(/@?(.*)/, '$1'),
      sender: msg.message.user.name,
      message: msg.match[3],
      date: today
    }
  )

  robot.brain.set('praises', currentPraises)
  robot.brain.save

getPraises = (msg, robot) ->
  msg.send "いいねログ"
  message = ""
  allPraises = robot.brain.get('praises')
  if allPraises
    for praise in allPraises
      message += "#{praise.date} #{praise.sender}さん が #{praise.receiver}さん にいいねしました \n\r";
    msg.send message
  else
    msg.send "いいねの履歴はありません"
