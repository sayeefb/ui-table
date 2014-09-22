#ui-th-sortable

    Polymer 'ui-th-sort-icon', {}


#ui-th-sortable

    Polymer 'ui-th',

### Change handlers

      directionChanged: -> 
        @applySort()
        @updateIcon()

      sortpropChanged: ->
        @applySort()

      colChanged: ->
        @applySort()

### updateIcon()
Call this to sync your sort icon with the current state

      updateIcon: ->
        sortIcon = @querySelector '[sort-icon]'
        sortIcon.setAttribute 'direction', @direction

### applySort()
Syncs `direction`,`sortprop`,`col` and `active` if they are unset or falsey
no event id dispatched.

Dispatches: `ui-table-sort`, { direction, prop, col }

      applySort: ->        
        return unless @direction?.length and @sortprop and @col and @active

        @fire 'ui-table-sort',
          direction: @direction
          prop: @sortprop
          col: @col

      toggleDirection: (event, detail, element) ->                      
        @direction = if @direction == 'asc' then 'desc' else 'asc'        
        @active = true

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
        @applySort()

      sortColumn: (event, descriptor) ->
        @sort = descriptor      
        
      updateHeaderSortStates: ->        
        sortables = @shadowRoot?.querySelectorAll "th [sortable]"        
                
        sortables?.array().forEach (sortable) =>              
          if sortable.getAttribute('col') != @sort.col
            sortable.setAttribute 'active', false
            sortable.setAttribute 'direction', ''
          else
            sortable.setAttribute 'active', true
            sortable.setAttribute 'direction', @sort.direction            
          
      applySort: ->        
        return unless @_value and @sort

        @updateHeaderSortStates()
        
        @_value.sort (a,b) =>        
          d = @sort
          compare = @sortFunctions[d.direction]
          
          left = @propParser a[d.col], d.prop
          right = @propParser b[d.col], d.prop

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
        @_value = @value?.slice(0) || [] #reference copy
        @_headers = [@_value[0]]        
        @applySort()        
      
       keys: Object.keys