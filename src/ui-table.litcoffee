#ui-table

    Polymer 'ui-table',

##Events

##Attributes and Change Handlers

##Methods

      getValue: (item, key) ->
        if typeof item == 'object'
          return item[key]
        else
          return item

      jsonChanged: (old_val, new_val) ->
        @format_json()

      if_int_sort: (item) ->
        if item isnt undefined and isNaN item
          return false
        else 
          return true

      comparator_non_int: (a, b) ->
        if window.sort_order == 1
          if window.getValue(a[window.sort_column], 'data') is undefined then return 1
          else if window.getValue(a[window.sort_column], 'data') < window.getValue(b[window.sort_column], 'data') then return -1
          else if window.getValue(a[window.sort_column], 'data') > window.getValue(b[window.sort_column], 'data')  then return 1
          return 0
        else
          if window.getValue(a[window.sort_column], 'data') is undefined then return 1
          else if window.getValue(a[window.sort_column], 'data') > window.getValue(b[window.sort_column], 'data') then return -1
          else if window.getValue(a[window.sort_column], 'data') < window.getValue(b[window.sort_column], 'data') then return 1
          return 0

      comparator_int: (a, b) ->
        if window.sort_order == 1
          if window.getValue(a[window.sort_column], 'data') is undefined then return 1
          else if Number window.getValue(a[window.sort_column], 'data') < Number window.getValue(b[window.sort_column], 'data') then return -1
          else if Number window.getValue(a[window.sort_column], 'data') > Number window.getValue(b[window.sort_column], 'data')  then return 1
          return 0
        else
          if window.getValue(a[window.sort_column], 'data') is undefined then return 1
          else if Number window.getValue(a[window.sort_column], 'data') > Number window.getValue(b[window.sort_column], 'data') then return -1
          else if Number window.getValue(a[window.sort_column], 'data') < Number window.getValue(b[window.sort_column], 'data') then return 1
          return 0

      format_json: ->
        columnList = []
        tempColumn = {}
        tempPreDef = []

        for item in @json.data
          do (item) =>
            for key of item
              if key not in columnList
                tempColumn.columnName = key
                if key not in @json.hiddenColumns
                  tempColumn.hidden = false
                  @shownColumns.push true
                else
                  tempColumn.hidden = true
                  @shownColumns.push false
                
                for p in @json.preDef
                  tempPreDef.push p.column

                if key in tempPreDef
                  @preDefColumns.push true
                else
                  @preDefColumns.push false

                columnList.push key
                @columns.push tempColumn
                tempColumn = {}

      search: (searchTerm) ->
        temp_data = []
        
        for item, i in @json.data
          do (item, searchTerm) =>
            for column, j in @columns
              if not @getValue item[column.columnName], 'data'
                temp_value = ""
              else
                temp_value = @getValue item[column.columnName], 'data'
                temp_value = temp_value.toString().toLowerCase()
              if temp_value.indexOf(searchTerm.toString().toLowerCase()) > -1
                itemLoc = []
                itemLoc.push j
                itemLoc.push i
                temp_data.push(itemLoc)
        temp_data

      filter: (selectedItems, filterByRows) ->
        temp_data = []
        if filterByRows
          for item, i in selectedItems
            temp_data.push @json.data[item[1]]
        temp_data

      clearSelectedItems: () ->
        for item, i in @itemSelected
          @itemSelected[i].removeAttribute('class', 'selectedCell')
        @itemSelected = []
          


##Event Handlers

      sort_data: () ->
        intSort = @if_int_sort item[@sort_column] for item in @json.data

        window.sort_column = @sort_column
        window.sort_order = @sort_order
        window.getValue = @getValue

        if intSort
          @json.data = @json.data.sort(@comparator_int)
        else
          @json.data = @json.data.sort(@comparator_non_int)


      sort: (e) ->
        columnName = e.target.id.substring(e.target.id.indexOf("_") + 1)
        if columnName is "" then columnName = e.target.parentElement.id.substring(e.target.parentElement.id.indexOf("_") + 1)

        switch columnName
          when @sort_column
            @sort_order = (@sort_order + 1) % 2
          else
            @sort_column = columnName
            @sort_order = 0

        @sort_data()

      filter_event: (e) ->
        targetElement = @itemSelected[0]
        target_column = targetElement.getAttribute 'data-column'
        target_value = targetElement.getAttribute('data').toLowerCase()

        if @filtered isnt true
          @backup_data = @json.data
          @filtered = true

        temp_data = []
        
        for item, i in @json.data
          do (item, target_column, target_value) =>
            temp_value = @getValue item[target_column], 'data'
            if not temp_value
              temp_value = ""
            else
              temp_value = temp_value.toString().toLowerCase()
            if temp_value is target_value
              temp_data.push(item)
        @clearSelectedItems()
        @json.data = temp_data

      reset_filter: ->
        @json.data = @backup_data
        @filtered = false
        @clearSelectedItems()

      row_click_event: (e) ->
        targetRow = Number e.target.getAttribute 'data-row'
        targetColumn = e.target.getAttribute 'data-column'
        targetColumnNumber = 0
        targetElement = e.target
        rowClickValue = @json.data[targetRow]

        for column, c in @columns
          if column.columnName is targetColumn then targetColumnNumber = c

        if @clickTimer and @clickTimer isnt null
          clearTimeout @clickTimer
          @clickTimer = null
          @fire 'ui-table-row-doubleClick', {"rowData": rowClickValue, "rowNum": targetRow}
          @fire 'ui-table-cell-doubleClick', {"cellData": rowClickValue[targetColumn], "cellRow": targetRow, "cellColumnName": targetColumn}
        else
          @clickTimer = setTimeout =>
            @clickTimer = null
            @clearSelectedItems()
            @itemSelected.push targetElement
            targetElement.setAttribute('class', 'selectedCell')
            @fire 'ui-table-cell-click', {"cellData": rowClickValue[targetColumn], "cellRow": targetRow, "cellColumnName": targetColumn}
            @fire 'ui-table-row-click', {"rowData": rowClickValue, "rowNum": targetRow}
          , 250

      search_filter: (e) ->
        searchText = @$.searchText.value
        filterLocations = []

        if searchText isnt ""
          filterLocations = @search searchText
          if @filtered isnt true
            @backup_data = @json.data
            @filtered = true
          @json.data = @filter filterLocations, true

##Polymer Lifecycle

      created: ->

      ready: ->

      attached: ->

      domReady: ->
        @filtered = false
        @itemSelected = []
        @columns=[]
        @shownColumns=[]
        @preDefColumns=[]

      detached: ->
