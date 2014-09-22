#ui-th-sortable

    Polymer 'ui-th',

      sortactiveChanged: ->
        @active = @sortactive == "true"
        @applySort()

      directionChanged: ->
        @applySort()

      sortpropChanged: ->
        @applySort()

      colChanged: ->
        @applySort()

      applySort: ->        
        return unless @direction and @active and @sortprop and @col        
        @fire 'ui-table-sort',
          direction: @direction
          prop: "#{@col}.#{@sortprop}"          

      toggleDirection: (event, detail, element) ->        
        @direction = if @direction == 'asc' then 'desc' else 'asc'

#ui-table 

    Polymer 'ui-table',
      
      propParser: (doc, prop) ->        
        prop.split('.').reduce (acc, p) -> 
          acc[p]
        , doc

      sortFunctions:
        asc: (a,b) -> a >= b
        desc: (a,b) -> a <= b

      sortColumn: (event, descriptor) ->      
        @sortDescriptor = descriptor
        @sort()

      sort: ->        
        return unless @_value and @sortDescriptor        
        @_value.sort (a,b) =>
          
          d = @sortDescriptor
          compare = @sortFunctions[d.direction]
          
          left = @propParser a, d.prop
          right = @propParser b, d.prop

          compare left, right

      withSortDescriptor: (obj) ->
        obj.sort = @sortDescriptor
        obj

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
        @_value = @value.slice(0) #reference copy
        @_headers = [@_value[0]]
        
        @sort()
      
       keys: Object.keys