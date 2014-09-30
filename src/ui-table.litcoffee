#ui-th-sort-icon
Reactive icon for the current sort direction on the ui-th

    Polymer 'ui-th-sort-icon', {}

#ui-th
An element to handle sorting of a particular column and upating its sort icon
if present.

    Polymer 'ui-th',

### Change handlers
Handlers that attempt to sync and only dispatch one event by calling `applySort()`.

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
Syncs `direction`,`sortprop`,`col` and `active`, if they are unset or falsey
no event is dispatched.

_Dispatches:_ `'ui-table-sort', { direction, prop, col }`

      applySort: ->        
        return unless @direction?.length and @sortprop and @col and @active

        @fire 'ui-table-sort',
          direction: @direction
          prop: @sortprop
          col: @col

### toggleDirection()
Event handler for when the header is clicked.  If the header is not active
then it will suppress `applySort()` from dispatching its event.

      toggleDirection: (event, detail, element) ->                      
        @direction = if @direction == 'asc' then 'desc' else 'asc'        
        @active = true if @sortable



#ui-table 
An element that allows you define templates for keys in rows of data and then builds
out a table for you.  Also responds to sorting events that can be dispatched by children.

    Polymer 'ui-table',

### sortFunctions
Comparators for native sort function. These can be overidden though I do not recommend it.

      sortFunctions:
        asc: (a,b) -> 
          if a is undefined or a is '' or a is null
            return 1
          else if b is undefined or b is '' or b is null
            return -1
          else if a <= b
            return -1
          else 
            return 1

        desc: (a,b) -> 
          if a is undefined or a is '' or a is null
            return 1
          else if b is undefined or b is '' or b is null
            return -1
          else if a >= b
            return -1
          else 
            return 1

### Cell Click Handler

### bubbleClickEvent
The cell that was clicked, will propegate 2 events for double click and 2 events for single click, 
1 each for row data, and cell data

      bubbleClickEvent: (e) ->
        targetElement = e.target

        if @clickTimer and @clickTimer isnt null
          clearTimeout @clickTimer
          @clickTimer = null
          @fire 'ui-table-cell-double-click',
            row: targetElement.getAttribute('row')
            column: targetElement.getAttribute('col')
            data: @_value[targetElement.getAttribute('row')][targetElement.getAttribute('col')]
          @fire 'ui-table-row-double-click',
            row: targetElement.getAttribute('row')
            column: targetElement.getAttribute('col')
            data: @_value[targetElement.getAttribute('row')]

        else 
          @clickTimer = setTimeout =>
            @clickTimer = null
            @fire 'ui-table-cell-click',
              row: targetElement.getAttribute('row')
              column: targetElement.getAttribute('col')
              data: @_value[targetElement.getAttribute('row')][targetElement.getAttribute('col')]
            @fire 'ui-table-row-click',
              row: targetElement.getAttribute('row')
              column: targetElement.getAttribute('col')
              data: @_value[targetElement.getAttribute('row')]

          , 300

### Change handlers

### sortChanged()
The `sort` property can be changed externally on the node or defined on your templates elements.

      sortChanged: -> @applySort()

### valueChanged()
When the value is changed it also builds out the headers off of the first row
in the `value` property.  This is likely to change. Sorting is also applied if applicable 

      valueChanged: ->
        @_value = @value?.slice(0) || [] #reference copy
        @_headers = [@_value[0]]
        @_value.forEach (item) =>
          Object.keys(item).forEach (key)=>
            if key not in Object.keys(@_headers[0])
              @_headers[0][key] = ''

        headerTemplateIds = []
        @shadowRoot.querySelectorAll("template[header]").array().forEach (item) ->
          headerTemplateIds.push item.getAttribute 'id'  
        Object.keys(@_headers[0]).forEach (item) =>
          if item+'-header' not in headerTemplateIds
            headerElem = document.createElement('template')
            headerElem.setAttribute('header', '')
            headerElem.setAttribute('name', item)
            headerElem.setAttribute('id', "#{item}-header")
            headerElem.innerHTML = "<ui-th sortable='true' sortprop='#{item}' col='#{item}'><span>#{item}</span><ui-th-sort-icon sort-icon></ui-th-sort-icon></ui-th>"
            @shadowRoot.appendChild headerElem

            cellElem = document.createElement('template')
            cellElem.setAttribute('column', '')
            cellElem.setAttribute('name', item)
            cellElem.setAttribute('id', "#{item}-cell")
            cellElem.innerHTML = "{{#{item}}}"
            @shadowRoot.appendChild cellElem

        @applySort()  

### sortColumn()
Change handler for the `ui-table-sort` event that is dispatched by child elements

      sortColumn: (event, descriptor) ->
        @sort = descriptor      

### updateHeaderSortStates()
Internal function that find all of the child sortable headers and attempts to 
reset their `direction` if they are not active.  For now only single column sort is handled.

      updateHeaderSortStates: ->        
        sortables = @shadowRoot?.querySelectorAll "th [sortable]"        
                
        sortables?.array().forEach (sortable) =>              
          if sortable.getAttribute('col') != @sort.col
            sortable.setAttribute 'active', false
            sortable.setAttribute 'direction', ''
          else
            sortable.setAttribute 'active', true
            sortable.setAttribute 'direction', @sort.direction            

### applySort()
Internal function that syncs `@_value` and `@sort`.  It updates the header states
and sorts the internal databound collection.

      applySort: ->        
        return unless @_value and @sort

        @updateHeaderSortStates()
        
        @_value.sort (a,b) =>        
          d = @sort
          compare = @sortFunctions[d.direction]
          
          leftVal = a[d.col]
          rightVal = b[d.col]

          if typeof a[d.col] is 'object'
            leftVal = @propParser a, d.prop
            rightVal = @propParser b, d.prop

          left = leftVal
          
          right = rightVal

          if left is null or left is undefined
            left = ''

          if typeof(left) isnt 'number'
            left = left.toLowerCase().trim()

          if right is null or right is undefined
            right = ''

          if typeof(right) isnt 'number'
            right = right.toLowerCase().trim()

          compare left, right

### addTemplates()
Templates from the Light DOM are <content> selected into the Shadow DOM, assigned a 
key so that in our repeaters we can user template references and delay binding our 
cell/header data.

      addTemplates: (nodes, type) ->        
        nodes.getDistributedNodes().array().forEach (t) =>
          col = t.getAttribute 'name'
          t.setAttribute 'id', "#{col}-#{type}"           
          @shadowRoot.appendChild t

### ready()
Reads cell and header templates once component is ready for use.

      ready: ->        
        @addTemplates @$.cells, 'cell'
        @addTemplates @$.headers, 'header'      

      

### keys(obj):Array
Filter used to transform to allow objects to be iterated over with `TemplateBinding.repeat`

      keys: Object.keys


### propParser(doc,prop):*
Takes a document and dot property string (ex. `'prop1.prop2'`) and returns the value
in the object for the nested property.

      propParser: (doc, prop) -> 
        prop.split('.').reduce (acc, p) -> 
          acc[p]
        , doc
