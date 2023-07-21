-- Simple Count for Total Population
select count(distinct unique_mem_id) as num_users
from yi_xpanelov6_20220816.bank_panel

select count(distinct unique_mem_id) as num_users
from yi_xpanelov6_20220816.card_panel

-- Create sample and store in my temp directory
CREATE TABLE temp_132.sample AS (SELECT *
                                        FROM yi_xpanelov6_20220816.bank_panel
                                        WHERE mod(unique_mem_id, 100) < 5
                                          AND optimized_transaction_date >= '2019-08-01'
                                            AND is_duplicate = 0)


-- Create card sample and store in temp directory
CREATE TABLE temp_132.sample_card AS (SELECT *
                                        FROM yi_xpanelov6_20220816.card_panel
                                        WHERE mod(unique_mem_id, 100) < 5
                                          AND optimized_transaction_date >= '2019-08-01'
                                        AND is_duplicate = 0)

-- Count By Month (saved to count_by_month.csv)
(select count(distinct unique_mem_id) as num_users, count(distinct unique_bank_account_id) as num_accounts,
       count(*) as num_transactions, 'bank' as source, month
from (select substring(optimized_transaction_date, 1, 7) as month, unique_mem_id, unique_bank_account_id
      from yi_xpanelov6_20220816.bank_panel WHERE mod(unique_mem_id, 100) = 1 ) as month_create
GROUP BY month
ORDER BY month)
UNION ALL
(select count(distinct unique_mem_id) as num_users, count(distinct unique_card_account_id) as num_accounts,
       count(*) as num_transactions, 'card' as source, month
from (select substring(optimized_transaction_date, 1, 7) as month, unique_mem_id, unique_card_account_id
      from yi_xpanelov6_20220816.card_panel WHERE mod(unique_mem_id, 100) = 1) as month_create
GROUP BY month
ORDER BY month)



-- Count Users/Transactions in the sample
select count(distinct unique_mem_id) as num_users,
       count(distinct unique_bank_account_id),
       count(*)                      as num_transactions
FROM yi_xpanelov6_20220816.bank_panel
WHERE mod(unique_mem_id, 100) < 5
  AND optimized_transaction_date >= '2019-08-01'
  AND is_duplicate = 0

-- User Score Dist (saved to user_score_dist.csv)
select unique_mem_id, avg(user_score), min(user_score), max(user_score), count(*)
FROM yi_xpanelov6_20220816.bank_panel
WHERE mod(unique_mem_id, 100) < 5
  AND is_duplicate = 0
  AND optimized_transaction_date >= '2020-01-01'
  AND optimized_transaction_date < '2020-02-01'
group by unique_mem_id


-- Filter 1 (By User Score)
create table temp_132.filter1 as (SELECT b.*, a.avg_user_score
                 from (select unique_mem_id,
                              avg(user_score) as avg_user_score
                       from temp_132.sample
                       group by unique_mem_id) a
                          inner join (select *
                                      from temp_132.sample) b
                                     on a.unique_mem_id = b.unique_mem_id
                 where avg_user_score > 6.5)

-- Filter 2:Find all Qualifying Federal/State/Local Payroll Transactions
create table temp_132.filter2 as (select *
                                  from (select *,
                                               CASE
                                                   WHEN ((upper(primary_merchant_name) like '%DFAS%' OR
                                                          upper(primary_merchant_name) like
                                                          '%U.S. DEPARTMENT OF THE TREASURY%' OR
                                                          upper(primary_merchant_name) like '%US TREASURY%' OR
                                                          upper(primary_merchant_name) like '%GOVERNMENT%' OR
                                                          upper(primary_merchant_name) like '%GSA%' OR
                                                          upper(primary_merchant_name) like
                                                          '%THE GENERAL SERVICES ADMINISTRATION%' OR
                                                          upper(primary_merchant_name) like
                                                          '%UNITED STATES COAST GUARD%' OR
                                                          upper(primary_merchant_name) like
                                                          '%U.S. DEPARTMENT OF HEALTH AND HUMAN SERVICES' OR
                                                          upper(primary_merchant_name) like
                                                          '%AGRICULTURAL TREASURY OFFICE%' OR
                                                          upper(primary_merchant_name) like '%CENSUS%' OR
                                                          upper(primary_merchant_name) like
                                                          '%SOCIAL SECURITY ADMINISTRATION%' OR
                                                          upper(primary_merchant_name) like '%FARM SERVICE AGENCY%' OR
                                                          description ilike '%FED SAL%'
                     or description ilike '%FAA TREAS 310%'
                     or description ilike '%EPA TREAS 310%'
                     or description ilike '%GSA TREAS 310%'
                     or description ilike '%DOI1 TREAS 310%'
                     or description ilike '%DOT4 TREAS 310%'
                     or description ilike '%NIH  TREAS 310%' or description ilike '%NIH. TREAS 310%'
                     or description ilike '%DHS  TREAS 310%'
                     or description ilike '%LOC1 TREAS 310%'
                     or description ilike '%USSS TREAS 310%'
                     or description ilike '%CBP  TREAS 310%'
                     or description ilike '%DOJ  TREAS 310%'
                     or description ilike '%USSS TREAS 310%'
                     or description ilike '%US HOUSE OF REP%'
                     or description ilike '%US SENATE FED SAL%'
                     or description ilike '%TENN VALLEY AUTH TRPDFEDSL%'
                     or description ilike '%TENN VALLEY AUTH ACH: TRPDFEDSL%'
                     or description ilike '%US SENATE FED SAL%'
                     or description ilike '%IN AF PAY%'
                     or description ilike '%IN ARMY ACT%'
                     or description ilike '%IN AF PAY%'
                     or description ilike '%IN AF RES%'
                     or description ilike '%IN ARMY RC%'
                     or description ilike '%NAVY ACT%'
                     or description ilike '%NAVY ALT%'
                     or description ilike '%NAVY RES%')
                                                       AND description not ilike '%SSA  TREAS 310%'
                     AND description not ilike '%SOC SEC%'
                     AND description not ilike '%VA BEN%'
                     AND description not ilike '%TREASURY PMN%'
                     AND description not ilike '%SERV F%'
                     AND description not ilike '%SUPP SEC%'
                     AND description not ilike '%US TREASURY CF%'
                     AND description not ilike '%TAX%'
                     AND description not ilike '%RET%'
                     AND description not ilike '%FED PAYMENT%'
                     AND description not ilike '%ALLT%'
                     AND description not ilike '%PPTAS%'
                     AND description not ilike '%BENEFIT PAYMENT%'
                     AND description not ilike '%TRAVEL PAY%'
                     AND description not ilike '%UI BEN%'
                     AND description not ilike '%USCIS%'
                     AND description not ilike '%VACP%'
                     AND description not ilike '%DCPS%'
                     AND description not ilike '%CASH%'
                     AND description not ilike '%IATS PAY%'
                     AND description not ilike '%MISC PAY%'
                     AND description not ilike '%NJ SDU%'
                     AND description not ilike '%TREAS 449%'
                     AND description not ilike '%SDP%'
                     AND description not ilike '%CHILD%'
                     AND description not ilike '%FAIRFAX%'
                     AND description not ilike '%GOVERNMENT SOLUTIONS%'
                     AND description not ilike '%GOVERNMENT SERVICES%'
                     AND description not ilike '%GOVERNMENT VI%'
                     AND description not ilike '%COUNTY%'
                     AND description not ilike '%EITX%'
                     AND description not ilike '%CITY%'
                     AND description not ilike '%ASI GOV%'
                     AND description not ilike '%STUDENT LN%'
                     AND description not ilike '%STATE%'
                     AND description not ilike '%POLICE%'
                     AND description not ilike '%NY %'
                     AND description not ilike '%OHIO%'
                     AND description not ilike '%AR.GOV%'
                     AND description not ilike '%NJMONT%'
                     AND description not ilike '%EDUCATION%'
                     AND description not ilike '%KANSAS%'
                     AND description not ilike '%NEWYORK%'
                     AND description not ilike '%SSA TREAS 310%'
                     AND description not ilike '%SBAD TREAS 310%'
                     AND description not ilike '%RRB  TREAS 310%'
                     AND description not ilike '%RRB TREAS 310%'
                     AND description not ilike '%DOEP TREAS%'
                     AND description not ilike '%DFEC TREAS 310%'
                     AND primary_merchant_name not ilike '%COUNTY%'
                     AND primary_merchant_name not ilike '%LOUISIANA%'
                     AND primary_merchant_name not ilike '%ACCO BRANDS%'
                     AND primary_merchant_name not ilike '%GOVERNMENT SOLUTIONS%'
                     AND primary_merchant_name not ilike '%ASCENSUS TRUST%'
                     AND primary_merchant_name not ilike '%US NAVY NSA PC MORALE WELFARE & RECREATION%'
                     AND primary_merchant_name not ilike '%SOCIAL SEC%'
                     AND primary_merchant_name not ilike '%GOVERNMENT SERVICES%'
                     AND primary_merchant_name not ilike '%FEDERAL RESERVE%') THEN 'federal'
                 WHEN ((upper(primary_merchant_name) like '%STATE TREASUR%' or
                        upper(primary_merchant_name) like '%STATE COMPTROL%' or
                        upper(primary_merchant_name) like '%STATE CONTROLLER%' or
                        upper(primary_merchant_name) like '%ST OF%' or
                        upper(primary_merchant_name) like '%STATE%' or
                        upper(primary_merchant_name) like '%COMMONWEALTH OF%' or
                        upper(primary_merchant_name) like '%DEPARTMENT OF%' or
                        upper(primary_merchant_name) like '%STATE DEPARTMENT%' or
                        (upper(primary_merchant_name) like '%STATE OF COLORADO' and
                         description not ilike '%COLORADO STATE U%') or
                        (upper(primary_merchant_name) like '%STATE OF ILLINOIS' and description ilike '%PAYROLL%') or
                        upper(primary_merchant_name) like '%LOUISIANA GOVERNMENT%')
                     and description not ilike '%TAX%'
                     and description not ilike '%UI%'
                     and description not ilike '%UNEMP%'
                     and description not ilike '%DSS%'
                     and description not ilike '%REFUND%'
                     and description not ilike '%BENEFIT%'
                     and description not ilike '%CHILD%'
                     and description not ilike '%EITX%'
                     and description not ilike '%SUPP%'
                     and upper(primary_merchant_name) not like '%U.S. DEPARTMENT OF THE TREASURY%'
                     and upper(primary_merchant_name) not like '%US TREASURY%'
                     and upper(primary_merchant_name) not like '%US DEPARTMENT OF EDUCATION%'
                     and upper(primary_merchant_name) not like '%U.S. DEPARTMENT OF HEALTH AND HUMAN SERVICES%'
                     and upper(primary_merchant_name) not like '%DEPARTMENT OF VETERAN%'
                     and upper(primary_merchant_name) not like '%UNITED STATES%'
                     and upper(primary_merchant_name) not like '%STAR OF%'
                     and upper(primary_merchant_name) not like '%TAX%'
                     and upper(primary_merchant_name) not like '%BLUE CROSS%'
                     and upper(primary_merchant_name) not like '%POWER%'
                     and upper(primary_merchant_name) not like '%HEALTH%'
                     and upper(primary_merchant_name) not like '%MEDIC%'
                     and upper(primary_merchant_name) not like '%UNIV%'
                     and upper(primary_merchant_name) not like '%ELECTRIC%'
                     and upper(primary_merchant_name) not like '%CORP%'
                     and upper(primary_merchant_name) not like '%AIRLINE%'
                     and upper(primary_merchant_name) not like '%PACIFIC%'
                     and upper(primary_merchant_name) not like '%TOOL%'
                     and upper(primary_merchant_name) not like '%CLEANER%'
                     and upper(primary_merchant_name) not like '%DINER%'
                     and upper(primary_merchant_name) not like '%EDISON%'
                     and upper(primary_merchant_name) not like '%EXPRESS%'
                     and upper(primary_merchant_name) not like '%SOUTHERN%'
                     and upper(primary_merchant_name) not like '%LOTTERY%'
                     and upper(primary_merchant_name) not like '%PRIME%'
                     and upper(primary_merchant_name) not like '%VISION%'
                     and upper(primary_merchant_name) not like '%EMC%'
                     and upper(primary_merchant_name) not like '%CENTRAL%'
                     and upper(primary_merchant_name) not like '%LIFE%'
                     and upper(primary_merchant_name) not like '%INSUR%'
                     and upper(primary_merchant_name) not like '%BERGEN%'
                     and upper(primary_merchant_name) not like '%ROADHOUSE%'
                     and upper(primary_merchant_name) not like '%CHILD%'
                     and upper(primary_merchant_name) not like '%TECH%'
                     and upper(primary_merchant_name) not like '%SPCA%'
                     and upper(primary_merchant_name) not like '%TOYOTA%'
                     and upper(primary_merchant_name) not like '%TIMES%'
                     and upper(primary_merchant_name) not like '%ZOO%'
                     and upper(primary_merchant_name) not like '%CENTER%'
                     and upper(primary_merchant_name) not like '%MADE%'
                     and upper(primary_merchant_name) not like '%DENT%'
                     and upper(primary_merchant_name) not like '%CNG%'
                     and upper(primary_merchant_name) not like '%SOURCE%'
                     and upper(primary_merchant_name) not like '%HOTEL%'
                     and upper(primary_merchant_name) not like '%RAILR%'
                     and upper(primary_merchant_name) not like '%FRESH%'
                     and upper(primary_merchant_name) not like '%YORKER%'
                     and upper(primary_merchant_name) not like '%THEATRE%'
                     and upper(primary_merchant_name) not like '%GRILL%'
                     and upper(primary_merchant_name) not like '%GENESEE%'
                     and upper(primary_merchant_name) not like '%FURNITURE%'
                     and upper(primary_merchant_name) not like '%EAST%'
                     and upper(primary_merchant_name) not like '%COLLEGE%'
                     and upper(primary_merchant_name) not like '%GAS%'
                     and upper(primary_merchant_name) not like '%UTILIT%'
                     and upper(primary_merchant_name) not like '%COFFEE%'
                     and upper(primary_merchant_name) not like '%HOSPITAL%'
                     and upper(primary_merchant_name) not like '%RETIR%'
                     and upper(primary_merchant_name) not like '%REVENUE%') THEN 'state'
                 WHEN ((primary_merchant_name ilike '%COUNTY%' or
       primary_merchant_name ilike '%CITY%' or
       primary_merchant_name ilike '%PUBLIC SCHOOL%' or
       primary_merchant_name ilike '%SCHOOL DISTRICT%' or
       description ilike '%COUNTY%' or
       description ilike '%CITY OF' or
       description ilike '%SCHOOL DISTRICT%')
  and description not ilike '%TAX%'
  and description not ilike '%HOSPIT%'
  and description not ilike '%UI%'
  and description not ilike '%DSS%'
  and description not ilike '%UNEMP%'
  and description not ilike '%REFUND%'
  and description not ilike '%BENEFIT%'
  and description not ilike '%CHILD%'
  and description not ilike '%PAYMENT%'
  and description not ilike '%GAS%'
  and description not ilike '%UTIL%'
  and description not ilike '%REVENUE%'
  and description not ilike '%RETIR%') THEN 'local'
                 ELSE 'other' END as fed
                                  from temp_132.filter1
                                  where transaction_base_type = 'credit'
                                    and transaction_category_name = 'Salary/Regular Income'
                                    and amount
                                      > 500) a
where fed not like 'other')



-- Calculate Share of Outside Income (returns a df of ids, total_income, qualifying_income, gov_ratio)
create table temp_132.filter3 as (
with filter3_totalincome as (select unique_mem_id, sum(amount) as total_income
                             from temp_132.sample
                             where transaction_base_type = 'credit'
                               and amount > 0
                               and transaction_category_name in
                                   ('Interest Income', 'Other Income',
                                    'Salary/Regular Income',
                                    'Sales/Services Income')
                             group by unique_mem_id),
     filter3_qualifyingincome as (select unique_mem_id, sum(amount) as qualifying_income
                                  from temp_132.filter2
                                  group by unique_mem_id),
     filter3_merge as (select a.unique_mem_id,
                              b.total_income,
                              a.qualifying_income,
                              a.qualifying_income * 100 / b.total_income as gov_income_ratio
                       from filter3_qualifyingincome a
                                inner join filter3_totalincome b
                                           on a.unique_mem_id = b.unique_mem_id
                       where gov_income_ratio >= 80) -- This is the threshold
select *
from filter3_merge
where unique_mem_id is not null)

--drop table temp_132.filter3
-- Filters 4 - 7 (Single Employer, Single Classification, Regular Intervals, Income Thresholds, Limited Volatility, Credit Card Match)

-- Single employer and single classification
create table temp_132.filter7 as (with nemployers as (select unique_mem_id,
                                                             count(distinct primary_merchant_name) as n_employers,
                                                             count(distinct fed)                   as n_classification
                                                      from temp_132.filter2
                                                      group by unique_mem_id
                                                      having n_employers = 1 -- one employer the whole time (as determined by merchant name)
                                                         and n_classification = 1 -- never switch from fed to state of vice verse
),
                                       payfreq as ( -- Payfrequency and volatility
                                           select unique_mem_id,
                                                  median(pay_freq)                   as median_pay_freq,
                                                  count(*)                           as n_paychecks,
                                                  stddev(amount) * 100 / avg(amount) as paycheck_vol
                                           from (select *,
                                                        lead(optimized_transaction_date) over
                                                            (partition by unique_mem_id order by optimized_transaction_date) -
                                                        filter2.optimized_transaction_date as pay_freq
                                                 from temp_132.filter2) a
                                           group by unique_mem_id
                                           having n_paychecks > 1
                                              and median_pay_freq >= 1
                                              and n_paychecks >= 900 / NULLIF(median_pay_freq, 0) -- required number of paychecks, roughly 3 years of paychecks)
                                              and paycheck_vol <= 35),
                                       elig as (select unique_mem_id,
                                                       sum(case
                                                               when optimized_transaction_date < '2020-09-01' and
                                                                    optimized_transaction_date >= '2019-09-01'
                                                                   then amount
                                                               else 0 end) as annual_income,
                                                       sum(case
                                                               when optimized_transaction_date < '2020-09-01' and
                                                                    optimized_transaction_date >= '2020-08-01'
                                                                   then amount
                                                               else 0 end) as monthly_income,
                                                       case
                                                           when (annual_income > 60000 or monthly_income * 12 > 5000) and annual_income <= 90000
                                                               then 'inelig'
                                                           else 'elig' end as elig
                                                from temp_132.filter2
                                                group by unique_mem_id
                                                having annual_income >= 30000
                                                   and monthly_income * 12 >= 30000),
                                       cardmatch as (select a.unique_mem_id, -- Must match card paydowns
                                                            a.paydown_from_bank,
                                                            b.paydown_from_card,
                                                            b.paydown_from_card * 100 / NULLIF(a.paydown_from_bank,0) as card_perc_observed
                                                     from (select unique_mem_id, sum(amount) as paydown_from_bank
                                                           from temp_132.sample
                                                           where transaction_base_type = 'debit'
                                                             and transaction_category_name = 'Credit Card Payments'
                                                           group by unique_mem_id) a
                                                              left join (select unique_mem_id, sum(amount) as paydown_from_card
                                                                          from temp_132.sample_card
                                                                          where transaction_base_type = 'credit'
                                                                            and transaction_category_name = 'Credit Card Payments'
                                                                          group by unique_mem_id) b
                                                                         on a.unique_mem_id = b.unique_mem_id
                                                     where (card_perc_observed >= 80
                                                       and card_perc_observed <= 120)
                                                       or card_perc_observed is null
                                                     and a.unique_mem_id is not null)
                                  select nemployers.*,
                                         median_pay_freq,
                                         n_paychecks,
                                         paycheck_vol,
                                         annual_income,
                                         monthly_income,
                                         elig,
                                         paydown_from_card,
                                         paydown_from_bank,
                                         card_perc_observed,
                                         total_income,
                                         qualifying_income,
                                         gov_income_ratio
                                  from nemployers
                                       inner join temp_132.filter3
                                                      on nemployers.unique_mem_id = temp_132.filter3.unique_mem_id
                                            inner join payfreq on filter3.unique_mem_id = payfreq.unique_mem_id
                                            inner join elig on payfreq.unique_mem_id = elig.unique_mem_id
                                            inner join cardmatch on elig.unique_mem_id = cardmatch.unique_mem_id)
-- drop table temp_132.filter7

-- Put it all together
-- drop table temp_132.final drop table temp_132.final_card

create table temp_132.final as (select sample.*, median_pay_freq,
                                         n_paychecks,
                                         paycheck_vol,
                                         annual_income,
                                         monthly_income,
                                         elig,
                                         paydown_from_card,
                                         paydown_from_bank,
                                         card_perc_observed,
                                         total_income,
                                         qualifying_income,
                                         gov_income_ratio, fed,
                                         case when (sum(case when fed = 'federal' then 1 else 0 end) over (partition by sample.unique_mem_id)) >= 1 then 'federal' else 'other' end as ever_fed
                                from temp_132.filter7
                                         inner join temp_132.sample on filter7.unique_mem_id = sample.unique_mem_id
                                         left join (select unique_bank_transaction_id, fed from temp_132.filter2) b
                                             on sample.unique_bank_transaction_id = b.unique_bank_transaction_id)

-- Put it all together for card file
create table temp_132.final_card as (
select sample_card.*, median_pay_freq,
                                         n_paychecks,
                                         paycheck_vol,
                                         annual_income,
                                         monthly_income,
                                         elig,
                                         paydown_from_card,
                                         paydown_from_bank,
                                         card_perc_observed,
                                         total_income,
                                         qualifying_income,
                                         gov_income_ratio, fed,
                                         ever_fed
from temp_132.filter7
inner join (select unique_mem_id, fed, case when (sum(case when fed = 'federal' then 1 else 0 end) over (partition by unique_mem_id)) >= 1 then 'federal' else 'other' end as ever_fed from temp_132.filter2 group by unique_mem_id, fed) b
    on filter7.unique_mem_id = b.unique_mem_id
left join temp_132.sample_card on b.unique_mem_id = sample_card.unique_mem_id)

select *
from temp_132.final_card
limit 10




















































