octicons = require("octicons")

command: "top -l 1 | grep -E '^CPU|^Phys'"

refreshFrequency: "1m"

render: (output) ->
  """
  <div class="cpu">
    #{octicons.pulse.toSVG()}
    <span class="icon percentage"></span>
  </div>
  """

update: (output, domEl) ->
  stats = output.split("\n")
  console.log(stats)
  cpuStats = stats[0]
  cpuPercs = cpuStats.split(":")[1].trim().split(",")
  userCpuPerc = cpuPercs[0].replace("user", "").trim()
  sysCpuPerc = cpuPercs[1].replace("sys", "").trim()
  $(".cpu span.icon.percentage", domEl).text("S:#{sysCpuPerc} U:#{userCpuPerc}")

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

    .cpu
      display: flex;
      align-items: center;
      justify-content: space-evenly;
  """
