-- Counting Number of Transactions and history in the sample
create table temp_132.user_history as (
select a.*, b.ever_fed, b.elig
from (select unique_mem_id, min(optimized_transaction_date) as min_date,
             max(optimized_transaction_date) as max_date, count(*) as n_transactions
from yi_xpanelov6_20220816.bank_panel
where mod(unique_mem_id,100) = 1
group by unique_mem_id) a
inner join (select unique_mem_id, ever_fed, elig from temp_132.final group by unique_mem_id, ever_fed, elig) b
on a.unique_mem_id = b.unique_mem_id)





-- Transaction Category By Fed, Elig
create table temp_132.category_weekly AS (select unique_mem_id,
                                                 yr_week,
                                                 transaction_base_type,
                                                 transaction_category_name,
                                                 ever_fed,
                                                 elig,
                                                 sum(amount)          as category_amt,
                                                 case
                                                     when transaction_category_name in
                                                          ('Deposits', 'Insurance', 'Retirement Contributions',
                                                           'Savings', 'Securities Trades', 'Transfers')
                                                         then 'savings/investment'
                                                     when transaction_category_name in ('Automotive/Fuel')
                                                         then 'auto'
                                                     when transaction_category_name in
                                                          ('Mortgage', 'Rent', 'Home Improvement', 'Utilities')
                                                         then 'housing'
                                                     when transaction_category_name in ('Education')
                                                         then 'education'
                                                     when transaction_category_name in ('Credit Card Payments', 'Loans')
                                                         then 'debtpaydown'
                                                     when transaction_category_name in
                                                          ('ATM/Cash Withdrawals', 'Cable/Satellite/Telecom',
                                                           'Charitable Giving',
                                                           'Electronics/General Merchandise',
                                                           'Entertainment/Recreation', 'Gifts', 'Groceries',
                                                           'Healthcare/Medical', 'Insurance', 'Office Expenses',
                                                           'Personal/Family', 'Pet Care', 'Postage/Shipping',
                                                           'Restaurants', 'Rewards', 'Services/Supplies',
                                                           'Subscriptions', 'Travel')
                                                         then 'nondurables'
                                                     else 'other' end as agg_category
                                          from (select *,
                                                       datediff(week, '2020-01-01', optimized_transaction_date) as yr_week
                                                from temp_132.final
                                                where optimized_transaction_date >= '2020-01-01') a
                                          group by unique_mem_id, yr_week, transaction_base_type,
                                                   transaction_category_name, ever_fed, elig)



select *
from temp_132.final
where optimized_transaction_date between '2022-01-01' and '2022-12-31'





select *
from temp_132.sample
where transaction_base_type = 'credit' and
      (description ilike '%UI BEN%' or
       description ilike '%UI PAY%' or
       description ilike '%UI PMT%' or
       description ilike '%DOL%' or
       description ilike 'NEB WORKFORCE UI' or
       description ilike '%LABOR' or
       description ilike '%UNEMP%')
  and description not ilike '%AK DEPT OF LABOR%'
  and description not ilike '%ADWS%'
  and description not ilike '%CDLE%'
  and description not ilike '%CT DOL%'
  and description not ilike '%CTDOL%'
  and description not ilike '%FL DEO%'
  and description not ilike '%GA DEPT OF LABOR%'
  and description not ilike '%ST OF IA%'
  and description not ilike '%ID DEPT OF LABOR%'
  and description not ilike '%IL DEPT OF EMPL SEC%'
  and description not ilike '%IL DEPT EMPL SEC%'
  and description not ilike '%ILLINOIS EPAY%'
  and description not ilike '%STATE OF INDIANA UI PAYMENT%'
  and description not ilike '%KS DEPT OF LABOR%'
  and description not ilike '%MARYLANDUNEMP%'
  and description not ilike '%MARYLAND ST UNEMP%'
  and description not ilike '%MASS UNEMPLOYMENT%'
  and description not ilike '%MAINE DEPT OF LABOR%'
  and description not ilike '%UIA PRE-PAID%'
  and description not ilike '%UIA PREPAID%'
  and description not ilike '%MODES%'
  and description not ilike '%MO UI BEN%'
  and description not ilike '%MN DEPT OF DEED%'
  and description not ilike '%MN DEPT OF / DEED%'
  and description not ilike '%MN UI PAY%'
  and description not ilike '%NCDES%'
  and description not ilike '%New Mexico DWS%'
  and description not ilike '%STATE OF NM%'
  and description not ilike '%JOB SERVICE ND%'
  and description not ilike '%NV UI PAYMENTS%'
  and description not ilike '%PADLIUCCON%'
  and description not ilike '%SCESC%'
  and description not ilike '%TN UI PAYMENTS%'
  and description not ilike '%TWC%'
  and description not ilike '%WA ST EMPLOY SEC%'
  and description not ilike '%VEC%'
  and description not ilike '%WYOMING DWS%'
  and description not ilike '%WISCONSIN DWD%'
  and description not ilike '%WISCONSIN UI TAX%'
  and description not ilike '%WORKFORCE WV%'


select *
from temp_132.sample
where transaction_base_type = 'credit' and
      description ilike '%AK DEPT OF LABOR%'
limit 150