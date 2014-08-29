#ui-table

    Polymer 'ui-table',

##Events

##Attributes and Change Handlers

##Methods

      test: (val)->
        console.log "testing", val

      jsonChanged: (old_val, new_val) ->
        @data = @format_json()

      dataChanged: (old_val, new_val) ->
        console.log "!@!@!@!@1", @row_click
        if @row_click isnt "true" and @row_click_adjusted isnt true
          @data.columns.unshift "row_click"
          for data in @data.data
            data.unshift ""
          @row_click_adjusted = true

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

      filter: (e) ->
        target_column = Number e.target.getAttribute 'data-column'
        target_value = e.target.textContent.toLowerCase()

        if @filtered isnt true then @backup_data = @data.data
        
        if @filtered isnt true then @filtered = true

        temp_data = []
        
        for item, i in @data.data
          do (item, target_column, target_value) =>
            temp_value = item[target_column].toString()
            if not temp_value
              temp_value = ""
            else
              temp_value = temp_value.toLowerCase()
            if temp_value is target_value
              temp_data.push(item)

        @data.data = temp_data

      reset_filter: ->
        @data.data = @backup_data
        @filtered = false

      row_click_event: (e) ->
        e = window.event || e
        if @clickTimer and @clickTimer isnt null
          console.log @clickTimer
          clearTimeout @clickTimer
          @clickTimer = null
        else 
          @clickTimer = setTimeout =>
            @clickTimer = null
            if @row_click is 'true'
              target_column = Number e.target.getAttribute 'data-column'
              row_click_value = @data.data[target_column][0]
              @fire 'ui-table-row-click', row_click_value
          , 500

##Polymer Lifecycle

      created: ->

      ready: ->

      attached: ->

      domReady: ->
        @filtered = false

      detached: ->
