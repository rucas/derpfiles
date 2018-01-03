octicons = require("octicons")

command: "echo $(./life.py)"

refreshFrequency: "1m"

render: (output) ->
  """
  <div class="motivation">
    #{octicons.heart.toSVG()}
    <span class="icon time"></span>
  </div>
  """

update: (output, domEl) ->
  $(".motivation span.time", domEl).text(output)

style: """
  -webkit-font-smoothing: antialiased
  font: 12px Hack
  color: #9C9486

  svg
    fill: #9C9486;
    padding-left: 5px;

  span
    padding-left: 5px;

  .motivation
    display: flex;
    align-items: center;
    justify-content: space-evenly;
"""
