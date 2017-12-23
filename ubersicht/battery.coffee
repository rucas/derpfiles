octicons = require("octicons")

command: "pmset -g batt | egrep '([0-9]+\%).*' -o"

refreshFrequency: "1m"

render: (output) ->
  """
  <div class="battery">
    <span class="icon percentage"></span>
    <span class="icon batt"></span>
    <span class="icon time-left"></span>
    #{octicons.plug.toSVG()}
  </div>
  """

update: (output, el) ->
  split = output.split(";")
  percentage = split[0]
  desc = split[2].trim()
  $battery = $(".battery span.icon.batt", el)
  $battery.removeClass("fa fa-battery-full fa-battery-three-quarters fa-battery-half fa-battery-quarter fa-battery-empty")
  $battery.addClass("fa #{@battery(parseInt(percentage))}")
  $(".battery span.icon.percentage", el).text(" #{percentage}")

  remainingTime = @remaining(desc)
  #$plug = $(".battery span.icon.plug", el)
  #$plug.addClass("fa fa-plug")
  $(".battery span.icon.time-left", el).text(" #{remainingTime} until")
  $(el).parent('div').css('order', 5)

###
TODO: Need to note difference between time left before plugging in
and time before completely charged
###
remaining: (desc) ->
  if desc.includes("no estimate")
    return "n/a"
  return desc.split(" ")[0]

battery: (percentage) ->
  return if percentage > 90
    "fa-battery-full"
  else if percentage > 70
    "fa-battery-three-quarters"
  else if percentage > 40
    "fa-battery-half"
  else if percentage > 20
    "fa-battery-quarter"
  else
    "fa-battery-empty"

style: """
  -webkit-font-smoothing: antialiased
  font: 12px Hack

  .battery
    display: flex;
    align-items: center;
    justify-content: space-evenly;

  svg
    fill: #9C9486;
    padding-left: 5px;

  span
    color: #9C9486
    padding-left: 5px;

  .battery .fa-battery-full
    color: #96C475;
  .battery .fa-battery-three-quarters
    color: #E5C07B;
  .battery .fa-battery-half
    color: #D19A66;
  .battery .fa-battery-quarter
    color: #E26B73;
"""
