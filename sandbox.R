


# Setup -------------------------------------------------------------------


rm(list = ls())


xfun::pkg_attach2('tidyverse', 'readxl', 'stats', 'sandwich', 'lmtest', 'ivreg', 'knitr', 
                  'lubridate', 'data.table')

proj <- dirname(rstudioapi::getSourceEditorContext()$path)

# Import ------------------------------------------------------------------


state_raw <- fread(file.path(proj, 'rawdata', 'stateemployees_subsamplesalary.csv')) %>% 
  mutate(optimized_transaction_date = ymd(optimized_transaction_date),
         yr_mon = lubridate::round_date(optimized_transaction_date, unit = 'month'),
         yr_week = paste0(lubridate::year(optimized_transaction_date), lubridate::week(optimized_transaction_date)) ,
         yr_week_start = lubridate::round_date(optimized_transaction_date, unit = 'week'))

federal_raw <- fread(file.path(proj, 'rawdata', 'federalemployees_subsamplesalary.csv')) %>% 
  mutate(optimized_transaction_date = ymd(optimized_transaction_date),
         yr_mon = lubridate::round_date(optimized_transaction_date, unit = 'month'),
         yr_week = paste0(lubridate::year(optimized_transaction_date), lubridate::week(optimized_transaction_date)) ,
         yr_week_start = lubridate::round_date(optimized_transaction_date, unit = 'week'))



# Remove Employers Manually ----------------------------------------------

federal <- federal_raw %>% 
  filter(!grepl("County|Power", primary_merchant_name) & 
           primary_merchant_name != 'Federal Reserve' &
           !grepl('Government Services', primary_merchant_name) &
           !grepl('Government Solutions', primary_merchant_name) &
           primary_merchant_name != "" &
           primary_merchant_name != 'Ascensus Trust' &
           primary_merchant_name != 'Gsa International') 

state <- state_raw %>% 
  filter(!grepl('Labor|Unemployment|Employment|Workforce|Job|Family|Lottery|Water|Economic Opportunity|Coffee', primary_merchant_name, ignore.case = T) &
           !grepl('Medicaid|Pizza|Parking', primary_merchant_name, ignore.case = T) &
           primary_merchant_name != 'United States Department Of Health And Human Services') 

combo <- state %>% bind_rows(federal) 


# Merge Summary Panel -----------------------------------------------------


user_summary <- fread(file.path(proj, 'rawdata', 'user_summary.csv')) %>% 
  mutate(yr_week = as.character(yr_week))

user_summary <- combo %>% 
  select(unique_mem_id, fed) %>% 
  distinct() %>% 
  inner_join(user_summary, by = c('unique_mem_id'))



# Summary Stats -----------------------------------------------------------

stat <- user_summary %>% 
  mutate(year = as.numeric(substr(yr_week,1,4)), week = as.numeric(substr(yr_week,5,6))) %>% 
  mutate(pre_event = case_when(year < 2020 | (year == 2020 & week <= 31) ~ 'pre_event', 
                               year == 2020 & week > 31 ~ 'event', 
                               TRUE ~ 'post_event')) %>% 
  group_by(unique_mem_id, fed, pre_event) %>% 
  summarise_at(vars(c('mortgage', 'rent', 'total_inflows', 'total_outflows',
                      'num_transactions', 'avg_user_score', 'savings', 'credit_card_payment',
                      'durables', 'nondurables', 'num_overdraft')), .funs = mean) %>% 
  group_by(fed) %>% 
  summarize(perc_homeowner = sum(mortgage > 1)*100/n(), 
            perc_renter = sum(rent > 1)*100/n(),
            perc_both = sum(mortgage > 1 & rent > 1)*100/n(),
            median_weekly_inflows = median(total_inflows),
            median_weekly_outflows = median(total_outflows),
            median_weekly_transactions = median(num_transactions),
            median_user_score = median(avg_user_score),
            median_savings = median(savings),
            median_credit_card_payment = median(credit_card_payment),
            median_durables = median(durables),
            median_nondurables = median(nondurables),
            total_n = n())
  
stat %>% t()


# Top Employers -----------------------------------------------------------


federal %>% 
  group_by(primary_merchant_name) %>% 
  summarize(unique_ids = uniqueN(unique_mem_id), total_paychecks = n()) %>% 
  arrange(desc(unique_ids)) %>% slice(1:15) 


state %>% 
  group_by(primary_merchant_name) %>% 
  summarize(unique_ids = uniqueN(unique_mem_id), total_paychecks = n()) %>% 
  arrange(desc(unique_ids)) %>% slice(1:15)


# Pay Frequency Analysis --------------------------------------------------

full_panel_users <- combo %>% 
  select(unique_mem_id, primary_merchant_name, optimized_transaction_date, amount, user_score, fed) %>% 
  group_by(unique_mem_id, primary_merchant_name) %>% 
  arrange(unique_mem_id, optimized_transaction_date) %>% 
  mutate(pay_gap = c(NA, diff(optimized_transaction_date))) %>% 
  summarize(modal_pay_gap = median(pay_gap, na.rm = T), n = n()) %>% 
  filter(n > 20, modal_pay_gap %in% c(14, 15, 29, 30, 31)) %>% 
  select(unique_mem_id)


# Main Graph --------------------------------------------------------------
  
combo %>% 
  group_by(unique_mem_id, yr_mon, fed) %>%
  summarize(monthly_pay = sum(amount, na.rm = T)) %>%
  group_by(unique_mem_id, fed) %>% 
  mutate(scaled_amount = monthly_pay/monthly_pay[which.min(yr_mon > '2020-01-01')]) %>% 
  group_by(yr_mon, fed) %>% 
  summarize(scaled_avg_pay = mean(scaled_amount)) %>%
  ggplot(aes(x = yr_mon, y = scaled_avg_pay, group = fed, color = fed)) +
  geom_line() +
  geom_vline(xintercept = ymd('2020-08-01'), color = 'black') +
  geom_vline(xintercept = ymd('2021-01-01'), color = 'black') +
  theme_bw() +
  theme(legend.position = 'bottom')


