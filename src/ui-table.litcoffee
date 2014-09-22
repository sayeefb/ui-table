#ui-th-sortable

    Polymer 'ui-th',
      directionChanged: ->        
        @sort null, null, true

      sort: (event, element, force=false) ->
        unless force
          @direction = if @direction == 'asc' then 'desc' else 'asc'

        @fire 'ui-table-sort', { direction: @direction, col: @col }   

#ui-table 

    Polymer 'ui-table',
      sortFunctions:
        asc: (a,b) -> a >= b
        desc: (a,b) -> a <= b

      sortColumn: (event, descriptor) ->        
        @sortDescriptor = descriptor
        console.log 'sortColumn'
        @sort()

      sort: ->
        debugger
        return unless @value and @sortDescriptor

        @value.sort (a,b) =>
          d = @sortDescriptor
          fn = @sortFunctions[d.direction]
          fn(a[d.col], b[d.col])

      wrapDistributedNodes: (nodes, type) ->
        nodes.getDistributedNodes().array().forEach (t) =>
          wrapper = document.createElement 'template'
          wrapper.setAttribute 'id', "#{t.getAttribute('col')}-#{type}"
          wrapper.innerHTML = t.outerHTML
          @shadowRoot.appendChild wrapper

      ready: ->
        @wrapDistributedNodes @$.cells, 'cell'
        @wrapDistributedNodes @$.headers, 'header'

      valueChanged: ->
        @_value = @value
        @_headers = [@value[0]]

        @sort() if @_value != @value
      
       keys: Object.keys