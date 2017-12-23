octicons = require("octicons")

command: "dig +short myip.opendns.com @resolver1.opendns.com && ifconfig | grep 'inet ' | grep -Fv 127.0.0.1 | awk '{print $2}'"

refreshFrequency: "1m"

render: (output) ->
  """
  <div class="network">
    #{octicons.server.toSVG()}
    <span class="ip"></span>
    #{octicons.rss.toSVG()}
    <span class="wlan"></span>
    #{octicons.home.toSVG()}
    <span class="ethernet"></span>
  </div>
  """

update: (output, domEl) ->
  ips = output.trim().split("\n")
  $(".network span.ip", domEl).text(" #{ips[0]}")
  $(".network span.wlan", domEl).text(" #{ips[1]}")
  if ips[2] is not undefined
    $(".network span.ethernet", domEl).text(" #{ips[2]}")
  else
    $(".network svg.octicon.octicon-home", domEl).hide()
  $(domEl).parent('div').css('order', -5)

style:
  """
    -webkit-font-smoothing: antialiased
    font: 12px Hack
    color: #9C9486

    svg
      fill: #9C9486;
      padding-left: 5px;

    span
      padding-left: 5px;

    .network
      display: flex;
      align-items: center;
      justify-content: space-evenly;
  """
