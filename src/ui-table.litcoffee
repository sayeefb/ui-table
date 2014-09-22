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

      sortChanged: ->
        @sortDescriptor = @sort
        @applySort()

      sortColumn: (event, descriptor) ->      
        @sortDescriptor = descriptor
        @applySort()

      applySort: ->        
        return unless @_value and @sortDescriptor        
        @_value.sort (a,b) =>
          
          d = @sortDescriptor
          compare = @sortFunctions[d.direction]
          
          left = @propParser a, d.prop
          right = @propParser b, d.prop

          compare left, right

      addTemplates: (nodes, type) ->        
        nodes.getDistributedNodes().array().forEach (t) =>
          col = t.getAttribute 'name'
          t.setAttribute 'id', "#{col}-#{type}"           
          @shadowRoot.appendChild t

      ready: ->        
        @addTemplates @$.cells, 'cell'
        @addTemplates @$.headers, 'header'        

      valueChanged: ->
        @_value = @value.slice(0) #reference copy
        @_headers = [@_value[0]]
        
        @applySort()
      
       keys: Object.keys