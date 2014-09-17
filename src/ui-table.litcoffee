#ui-table 

    Polymer 'ui-safe',

      valueChanged: () ->
        @html.model = @value

      attached: () ->             
        if @html and @html.constructor is Array
          @html.forEach (h) =>  
            @shadowRoot.appendChild h
        else if @html
          @shadowRoot.appendChild @html

#ui-table 

    Polymer 'ui-table',

      generateCells: (row) ->          
        cellMap = @cells.reduce (acc, template) ->          
          t = document.createElement 'template'
          t.setAttribute 'bind', '{{data}}'
          t.innerHTML = template.innerHTML                  
          acc[template.getAttribute('col')] = t
          acc
        , {}
      
        Object.keys(row).map (key) ->
          template = cellMap[key]
          template.key = key
          template.model = data: row[key] if template
          template 

      generateHeaders: ->
        return [] unless @headers
        @headers.map (header) =>
          { col: header.getAttribute('col'), html: header.childNodes.array() }

      attached: ->

        @cells = @$.cellTemplates.getDistributedNodes().array()
        @headers = @$.headerTemplates.getDistributedNodes().array()