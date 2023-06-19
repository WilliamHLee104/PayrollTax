


rm(list = ls())


xfun::pkg_attach2('tidyverse', 'readxl', 'stats', 'sandwich', 'lmtest', 'ivreg', 'knitr', 
                  'lubridate')


proj <- dirname(rstudioapi::getSourceEditorContext()$path)









# Setup -------------------------------------------------------------------

state <- read.csv(file.path(proj, 'rawdata', 'stateemployees.csv'))

federal <- read.csv(file.path(proj, 'rawdata', 'federalemployees.csv'))

state %>% 
  bind_rows(federal) %>% 
  mutate(optimized_transaction_date = ymd(optimized_transaction_date),
         yr_mon = lubridate::round_date(optimized_transaction_date, unit = 'month'),
         yr_week = lubridate::round_date(optimized_transaction_date, unit = 'week')) %>% 
  group_by(unique_mem_id, yr_mon, fed) %>%
  summarize(monthly_pay = sum(amount, na.rm = T)) %>%
  group_by(unique_mem_id, fed) %>% 
  mutate(scaled_amount = monthly_pay/monthly_pay[which.min(yr_mon > '2020-01-01')]) %>% 
  group_by(yr_mon, fed) %>% 
  summarize(scaled_avg_pay = mean(scaled_amount)) %>% 
  ggplot(aes(x = yr_mon, y = scaled_avg_pay, group = fed, color = fed)) +
  geom_line()


