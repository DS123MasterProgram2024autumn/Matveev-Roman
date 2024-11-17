library(scales)
library(shiny)
library(ggplot2)
library(dplyr)
library(DT)
library(RSQLite)

db_path <- "taxi_orders.db"

ui <- fluidPage(
  titlePanel("Аналіз доходів та кількості замовлень по місяцях"),
  sidebarLayout(
    sidebarPanel(
      dateRangeInput("date_range", "Виберіть діапазон місяців:", 
                       start = "2019-01-01", 
                       end =   "2019-12-31", 
                       min =   "2019-01-01",
                       max =   "2019-12-31",
                       format = "yyyy-mm",
                     ),
      actionButton("calculate", "Розрахувати дані")
    ),
    mainPanel(
      uiOutput("output_ui")  # Динамічний UI для таблиці чи графіка
    )
  )
)

server <- function(input, output) {
  
  observeEvent(input$calculate, {
    conn <- dbConnect(SQLite(), dbname = db_path)
    
    # SQL-запит для агрегації даних по місяцях
    query <- "SELECT strftime('%Y-%m', create_date) AS month, 
                     SUM(tariff) AS total_income, 
                     COUNT(*) AS order_count 
              FROM orders 
              WHERE create_date BETWEEN ? AND ? 
              GROUP BY month"
    
    # Виконання запиту з діапазоном дат, вказаним користувачем
    data <- dbGetQuery(conn, query, params = list(format(input$date_range[1], "%Y-%m"), 
                                                  format(input$date_range[2], "%Y-%m")))
    
    dbDisconnect(conn)
    
    # Візуалізація даних у вигляді таблиці та графіка
    output$output_ui <- renderUI({
      tagList(
        h3("Аналіз доходів та кількості замовлень по місяцях"),
        DTOutput("incomeTable"),
        plotOutput("incomeChart")
      )
    })
    
    # Таблиця з результатами
    output$incomeTable <- renderDT({
      datatable(data, options = list(pageLength = 5), 
                colnames = c("Місяць", "Загальний дохід (BYN)", "Кількість замовлень"))
    })
    
    # Графік доходів та кількості замовлень по місяцях
    output$incomeChart <- renderPlot({
      ggplot(data, aes(x = month)) +
        geom_col(aes(y = total_income, fill = "Дохід"), position = "dodge") +
        geom_line(aes(y = order_count, group = 1, color = "Кількість замовлень"), size = 1) +
        scale_y_continuous(
          name = "Дохід (BYN)",
          labels = comma,  # Застосування форматування із комами для поділу тисяч
          sec.axis = sec_axis(~., name = "Кількість замовлень")
        ) +
        labs(title = "Дохід та кількість замовлень по місяцях",
             x = "Місяць") +
        theme_minimal() +
        scale_fill_manual(name = "", values = c("Дохід" = "#00AFBB")) +
        scale_color_manual(name = "", values = c("Кількість замовлень" = "#FC4E07"))
    })
  })
}

shinyApp(ui = ui, server = server)
