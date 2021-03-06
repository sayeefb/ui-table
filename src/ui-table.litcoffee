#ui-table

    Polymer 'ui-table',

##Events

##Attributes and Change Handlers

##Methods

      jsonChanged: (old_val, new_val) ->
        @data = @format_json()

      dataChanged: (old_val, new_val) ->
        if @rowClickReturn isnt "true" and @rowClickAdjusted isnt true
          @data.columns.unshift ""
          for data in @data.data
            data.unshift ""
          @rowClickAdjusted = true

      if_int_sort: (item) ->
        if item isnt undefined and isNaN item
          return false
        else 
          return true

      comparator_non_int: (a, b) ->
        if window.sort_order == 1
          if a[window.sort_column] is undefined then return 1
          else if a[window.sort_column] < b[window.sort_column] then return -1
          else if a[window.sort_column] > b[window.sort_column] then return 1
          return 0
        else
          if a[window.sort_column] is undefined then return 1
          else if a[window.sort_column] > b[window.sort_column] then return -1
          else if a[window.sort_column] < b[window.sort_column] then return 1
          return 0

      comparator_int: (a, b) ->
        if window.sort_order == 1
          if a[window.sort_column] is undefined then return 1
          else if Number a[window.sort_column] < Number b[window.sort_column] then return -1
          else if Number a[window.sort_column] > Number b[window.sort_column] then return 1
          return 0
        else
          if a[window.sort_column] is undefined then return 1
          else if Number a[window.sort_column] > Number b[window.sort_column] then return -1
          else if Number a[window.sort_column] < Number b[window.sort_column] then return 1
          return 0

      format_json: ->
        temp_data = {}
        temp_data.columns = []
        temp_data.data = []
        temp_item = []

        for item in @json
          do (item) =>
            for key of item
              do (key) =>
                if key not in temp_data.columns then temp_data.columns.push key
        for item in @json
          do (item) =>
          for key in temp_data.columns
            temp_item.push(item[key])
          temp_data.data.push(temp_item)
          temp_item = []

        return temp_data

      search: (searchTerm) ->
        temp_data = []
        
        for item, i in @data.data
          do (item, searchTerm) =>
            for column, j in @data.columns
              temp_value = item[j]
              if not temp_value
                temp_value = ""
              else
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
            temp_data.push @data.data[item[1]]
        temp_data
          


##Event Handlers

      sort_data: () ->
        int_sort = @if_int_sort item[@sort_column] for item in @data.data
        window.sort_column = @sort_column
        window.sort_order = @sort_order

        if int_sort
          @data.data = @data.data.sort(@comparator_int)
        else
          @data.data = @data.data.sort(@comparator_non_int)


      sort: (e) ->
        target_id = e.target.id.substring(e.target.id.indexOf("_") + 1)
        if target_id is "" then target_id = e.target.parentElement.id.substring(e.target.parentElement.id.indexOf("_") + 1)

        switch parseInt(target_id)
          when @sort_column
            @sort_order = (@sort_order + 1) % 2
          else
            @sort_column = parseInt(target_id)
            @sort_order = 0

        @sort_data()

      filter_event: (e) ->
        targetElement = @itemSelected.pop()
        target_column = Number targetElement.getAttribute 'data-column'
        target_value = targetElement.textContent.toLowerCase()

        if @filtered isnt true
          @backup_data = @data.data
          @filtered = true

        temp_data = []
        
        for item, i in @data.data
          do (item, target_column, target_value) =>
            temp_value = item[target_column]
            if not temp_value
              temp_value = ""
            else
              temp_value = temp_value.toString().toLowerCase()
            if temp_value is target_value
              temp_data.push(item)

        @data.data = temp_data

      reset_filter: ->
        @data.data = @backup_data
        @filtered = false

      row_click_event: (e) ->
        targetRow = Number e.target.getAttribute 'data-row'
        targetColumn = Number e.target.getAttribute 'data-column'
        targetElement = e.target

        if @clickTimer and @clickTimer isnt null
          clearTimeout @clickTimer
          @clickTimer = null
          rowClickValue = @data.data[targetRow][0]
          if @rowClickReturn is 'true'
            @fire 'ui-table-row-click', rowClickValue
        else 
          @clickTimer = setTimeout =>
            @clickTimer = null
            if @itemSelected.length > 0
              @itemSelected[0].removeAttribute('class', 'selectedCell')
              @itemSelected.pop()
            @itemSelected.push targetElement
            targetElement.setAttribute('class', 'selectedCell')
          , 500

      search_filter: (e) ->
        searchText = @$.searchText.value
        filterLocations = []

        if searchText isnt ""
          filterLocations = @search searchText
          if @filtered isnt true
            @backup_data = @data.data
            @filtered = true
          @data.data = @filter filterLocations, true

##Polymer Lifecycle

      created: ->

      ready: ->

      attached: ->

      domReady: ->
        @filtered = false
        @itemSelected = []

      detached: ->
