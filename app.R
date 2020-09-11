library(shiny)

withHash <- function(file, directory = "www") {
  directory <- slashDir(directory)
  paste0(file, "?", as.character(tools::md5sum(paste0(directory, file))))
}

hashFiles <- function(files, directory){
  if (length(files) > 0){
    sapply(
      X = files,
      FUN = withHash,
      directory = directory,
      USE.NAMES = FALSE
    )
  } else {
    NULL
  }
}

getFullWidgetDir <- function(widgetId){
  system.file("widgets", widgetId)
}



getWidgetDependencies <- function(widgetId,
                                  jsFiles = NULL,
                                  cssFiles = NULL,
                                  version = "1.0.0"){
  # Directory for md5 check (hash) must be absolute
  fullDir <- getFullWidgetDir(widgetId)
  
  htmltools::htmlDependency(
    name = widgetId,
    version = version,
    src = c(href = paste0("avengers/widgets/", widgetId)),
    script = hashFiles(
      files = jsFiles,
      directory = fullDir
    ),
    stylesheet = hashFiles(
      files = cssFiles,
      directory = fullDir
    )
  )
}

slashDir <- function(directory){
  if (!grepl("/$", directory)) {
    paste0(directory, "/")
  } else {
    directory
  }
}

selectTag <- function(class, choices = list()) {
  lst <- structure(
    avengersBase::napply(
      lst = choices,
      fn = function(value, name) {
        shiny::tags$option(value = value, name)
      }
    ),
    names = NULL
  )
  
  if (!is.null(class)) {
    lst$class <- class
  }
  
  do.call(
    shiny::tags$select,
    lst
  )
}

gridSelect <- function(inputId, inputData = list()) {
  dep <- getWidgetDependencies(
    widgetId = 'gridSelect',
    jsFiles = c('gridSelect.js'),
    cssFiles = c('gridSelect.css')
  )
  if (is.null(inputData$groups) ||
      is.null(inputData$sessionGroups) ||
      is.null(inputData$sessions) ||
      is.null(inputData$tissue)) {
    return(shiny::tags$p('INVALID INPUT for gridSelect'))
  }
  shiny::tags$div(
    class = 'row-grid-control',
    id = inputId,
    shiny::tags$header(
      shiny::tags$ul(
        shiny::tags$li(
          shiny::tags$h6("Reference")
        ),
        shiny::tags$li(
          shiny::tags$h6("Comparison")
        )
      )
    ),
    shiny::tags$ul(
      shiny::tags$li(
        class = "grid-control-pair",
        shiny::tags$p(
          class = "error-message",
          "* Each comparison must be unique"
        ),
        shiny::tags$h2("Comparison pair"),
        shiny::tags$p(
          class = "error-message",
          "* Each comparison must be unique"
        ),
        shiny::tags$a(
          class = "remove-pair",
          "×"
        ),
        shiny::tags$ul(
          class = "reference-column",
          `data-name` = "group",
          shiny::tags$li(
            shiny::tags$label('Reference group'),
            shiny::tags$div(
              class = 'select-component',
              selectTag(
                class = 'reference-group',
                choices = inputData$groups
              )
            )
          ),
          shiny::tags$li(
            class = "reference-column",
            `data-name` = "session",
            shiny::tags$label('Reference session'),
            shiny::tags$div(
              class = 'select-component',
              selectTag(
                class = 'reference-session',
                choices = inputData$sessions
              )
            )
          ),
          shiny::tags$li(
            class = "reference-column",
            `data-name` = "sessionGroup",
            shiny::tags$label('Reference session group'),
            shiny::tags$div(
              class = 'select-component',
              selectTag(
                class = 'reference-session-group',
                choices = inputData$sessionGroups
              )
            )
          ),
          shiny::tags$li(
            class = "reference-column",
            `data-name` = "tissue",
            shiny::tags$label('Reference tissue'),
            shiny::tags$div(
              class = 'select-component',
              selectTag(
                class = 'reference-session-group',
                choices = inputData$tissue
              )
            )
          ),
          ## second column
          shiny::tags$li(
            class = "comparison-column",
            `data-name` = "group",
            shiny::tags$label('Comparison group'),
            shiny::tags$div(
              class = 'select-component',
              selectTag(
                class = 'comparison-group',
                choices = inputData$groups
              )
            )
          ),
          shiny::tags$li(
            class = "comparison-column",
            `data-name` = "session",
            shiny::tags$label('Comparison session'),
            shiny::tags$div(
              class = 'select-component',
              selectTag(
                class = 'comparison-session',
                choices = inputData$sessions
              )
            )
          ),
          shiny::tags$li(
            class = "comparison-column",
            `data-name` = "sessionGroup",
            shiny::tags$label('Comparison session group'),
            shiny::tags$div(
              class = 'select-component',
              selectTag(
                class = 'comparison-session-group',
                choices = inputData$sessionGroups
              )
            )
          ),
          shiny::tags$li(
            class = "comparison-column",
            `data-name` = "tissue",
            shiny::tags$label('Comparison tissue'),
            shiny::tags$div(
              class = 'select-component',
              selectTag(
                class = 'comparison-session-group',
                choices = inputData$tissue
              )
            )
          )
        )
      )
    ),
    shiny::tags$a(
      class = 'add',
      '+ Add to compare'
    ),
    dep
  )
}


expensiveCalcuation <- function() {
  future({
    Sys.sleep(5)
  })
}

ui <- fluidPage(
  uiOutput("xxx"),
  shiny::tags$div(
    class = "hidden",
    selectizeInput('_______________', '_____', list())
  )
)

server <- function(input, output, session) {
  output$xxx <- renderUI({
    gridSelect("fooBar", list(
      groups = list(foo = 10, bar = 20),
      sessions = list(hey = 1, yo = 2),
      sessionGroups = list(hello = 3, world = 5),
      tissue = list(t1 = 1000, t2 = 400)
    ))
  })
  count <- 0
  observeEvent(input$fooBar, {
    print('---------------------------')
    print(paste("::", count))
    print('---------------------------')
    count <<- count + 1
    print(input$fooBar)
  })
}

shinyApp(ui, server)
