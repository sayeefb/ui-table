#ui-table
IOS inspired navigation stack. This consists of a `ui-navigation` element
wrapped around and number of `ui-view` elements.

Inside each screen, you decorate elements with `push-screen="id"` attributes so
that clicking those elements automaticaly navigates. No need to put in any
event handlers, this is all declarative.


    Polymer 'ui-table',

##Events

##Attributes and Change Handlers

##Methods

      if_int_sort: (item) ->
        if isNaN item
          return false
        else 
          return true

      comparator_non_int: (a, b) ->
        if window.sort_order == 1
          if a[window.sort_column] < b[window.sort_column] then return -1
          if a[window.sort_column] > b[window.sort_column] then return 1
          return 0
        else
          if a[window.sort_column] > b[window.sort_column] then return -1
          if a[window.sort_column] < b[window.sort_column] then return 1
          return 0

      comparator_int: (a, b) ->
        if window.sort_order == 1
          if Number a[window.sort_column] < Number b[window.sort_column] then return -1
          if Number a[window.sort_column] > Number b[window.sort_column] then return 1
          return 0
        else
          if Number a[window.sort_column] > Number b[window.sort_column] then return -1
          if Number a[window.sort_column] < Number b[window.sort_column] then return 1
          return 0

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
            if item[target_column].toLowerCase() is target_value
              temp_data.push(item)

        @data.data = temp_data

      reset_filter: ->
        @data.data = @backup_data
        @filtered = false

##Polymer Lifecycle

      created: ->

      ready: ->

      attached: ->

      domReady: ->
        @filtered = false

      detached: ->
