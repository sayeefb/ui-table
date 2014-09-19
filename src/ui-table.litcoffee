#ui-table 

    Polymer 'ui-table',

      wrapDistributedNodes: (nodes, type) ->
        nodes.getDistributedNodes().array().forEach (t) =>
          wrapper = document.createElement 'template'
          wrapper.setAttribute 'id', "#{t.getAttribute('col')}-#{type}"
          wrapper.innerHTML = t.innerHTML
          @shadowRoot.appendChild wrapper

      ready: ->
        @wrapDistributedNodes @$.cells, 'cell'
        @wrapDistributedNodes @$.headers, 'header'

      valueChanged: ->        
        @_value = @value
        @_headers = [@value[0]]
      
       keys: Object.keys