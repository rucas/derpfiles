alignItems     : 'center'    # default: 'stretch'
alignContent   : 'center'    # default: 'stretch'
flexDirection  : 'row'        # default: 'row'
flexWrap       : 'nowrap'       # default: 'nowrap'
justifyContent : 'flex-end' # default: 'flex'-start'

refreshFrequency: false

render: () ->
  """
  <link rel="stylesheet" href="./assets/font-awesome/css/font-awesome.min.css" />
  <style>
    #__uebersicht {
      display: flex;
      height: 20px;
      position: relative;
      align-items: #{@alignItems};
      align-content: #{@alignContent};
      flex-direction: #{@flexDirection};
      flex-wrap: #{@flexWrap};
      justify-content: #{@justifyContent};
      background-color: #1F1F1F
    }
    #__uebersicht>div {
      width: auto;
      padding: 20px;
    }
    .widget {
      position: relative;
    }
  </style>
  """

update: (output, domEl) ->
  $(domEl).parent('div').hide()
