-- Counting Number of Transactions and history in the sample
create table temp_132.user_history as (
select a.*, b.ever_fed, b.elig
from (select unique_mem_id, min(optimized_transaction_date) as min_date,
             max(optimized_transaction_date) as max_date, count(*) as n_transactions
from yi_xpanelov6_20220816.bank_panel
where mod(unique_mem_id,100) < 5
group by unique_mem_id) a
inner join (select unique_mem_id, ever_fed, elig from temp_132.final group by unique_mem_id, ever_fed, elig) b
on a.unique_mem_id = b.unique_mem_id)

select ever_fed, elig, count(distinct unique_mem_id), avg(n_transactions) as avg_observations,
       avg(datediff(day, min_date, '2020-09-01')) as days_before, avg(datediff(day, '2020-09-01',max_date)) days_after,
       avg(datediff(day, min_date, max_date)) as avg_range
from temp_132.user_history
group by ever_fed, elig
order by ever_fed, elig




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


-- Unemployment Strings
select description,
       case
           when description ilike '%AK DEPT OF LABOR%' then 'AK'
           when description ilike '%STATE OF ARIZONA%' and description ilike '%BENEFITPAY' then 'AZ'
           when description ilike '%ADWS%' and
                (description ilike '%UI BENEFIT%' or description ilike '%ADWS PUABENEFIT%') then 'AR'
           when description ilike '%CDLE UI BENEFITS%' then 'CD'
           when description ilike '%CTDOL UNEMP%' then 'CT'
           when description ilike '%DELABOR UNEMPINS%' then 'DE'
           when description ilike '%D.C. EMPL%' then 'DC'
           when description ilike '%FL DEO%' and description ilike '%UI BENEFIT%' then 'FL'
           when description ilike '%GA DEPT OF LABOR%' and description ilike '%UI%' then 'GA'
           when description ilike '%ID DEPT OF LABOR%' or description ilike '%IL DEPT OF EMPL SEC%'
               or description ilike '%IL DEPT EMPL SEC%' or description ilike '%ILLINOIS EPAY%' then 'IL'
           when description ilike '%STATE OF INDIANA%' and description ilike '%UI PAYMENT%' then 'IN'
           when description ilike '%ST OF IA%' and description ilike '%UI PAY%' then 'IA'
           when description ilike '%KS DEPT OF LABOR%' and description ilike '%UNEMP%' then 'KS'
           when description ilike '%UNEMPLOYMENT INS BENEFITS%' then 'KY'
           when description ilike '%LOUISIANA WORKFO%' then 'LA'
           when description ilike '%MAINE DEPT%' and description ilike '%LABOR%' and description ilike '%UNEMP%'
               then 'ME'
           when description ilike '%MARYLAND%' and description ilike '%unemp%' then 'MD'
           when description ilike '%Massachusetts DUA%' or description ilike '%MA PUA%' or
                primary_merchant_name ilike '%Massachusetts Department of Unemployment%' then 'MA'
           when description ilike '%UIA PRE-PAID%' or description ilike '%UIA PREPAID%' then 'MI'
           when description ilike '%MN DEPT OF DEED%' or description ilike '%MN DEPT OF / DEED%' then 'MN'
           when description ilike '%MDES BENEFITSUI%' then 'MS'
           when description ilike '%MODES %' and description ilike '%UI BENEFIT%' then 'MO'
           when description ilike '%STATE OF MONTANA%' then 'MT'
           when description ilike '%NEB WORKFORCE UIPAYMENT%' then 'NE'
           when description ilike '%NEVADA ESD%' or description ilike '%NV UI PAYMENTS%' then 'NV'
           when description ilike '%NHUS NHUC BEN%' then 'NH'
           when description ilike '%STATE OF NJ' and (description ilike '%UNEMP%' or description ilike '%DUA%')
               then 'NJ'
           when (description ilike '%New Mexico DWS%' or description ilike '%State of NM%') and description ilike '%UI%'
               then 'NM'
           when description ilike '%NYS DOL UI%' then 'NY'
           when description ilike '%NCDES%' and description ilike '%UIBEN%' then 'NC'
           when description ilike '%JOB SERVICE ND%' then 'ND'
           when description ilike '%ODJFS%' then 'OH'
           when description ilike '%EMPLOYMT BENEFIT%' and description ilike '%UI BENEFIT%' then 'OR'
           when description ilike '%COMM OF PA UCD' or description ilike '%PADLIUCCON%' then 'PA'
           when description ilike '%RIDLT-UI UIDD%' then 'RI'
           when description ilike '%SCESC%' then 'SC'
           when description ilike '%TNUIDD PAYMENT%' or description ilike '%TN UI PAYMENTS%' then 'TN'
           when description ilike '%TWC%' and description ilike '%BENEFIT%' then 'TX'
           when description ilike '%UI BEN EFT%' then 'UT'
           when description ilike '%VDOL%' and description ilike '%PUA%' then 'VT'
           when description ilike '%VEC%' and description ilike '%UI%' then 'VA'
           when description ilike '%WA ST EMPLOY%' and description ilike '%UI%' then 'WA'
           when description ilike '%WORKFORCE WV%' then 'WV'
           when description ilike '%WISCONSIN%' and (description ilike '%DWD%' or description ilike '%UI%') then 'WI'
           when description ilike '%WYOMING DWS%' and description ilike '%UI%' then 'WY'
           when description ilike '%DEPT OF LABOR%' and description ilike '%UNEMPLYMNT%' then 'AL'
           when description ilike '%DEPT OF LABOR%' and description ilike 'UI BENEFIT%' then 'HI'
           else NULL end as ui_transaction,
       primary_merchant_name
from temp_132.sample
where transaction_base_type = 'credit'
  and (description ilike '%UI BEN%'
    or description ilike '%UI PAY%'
    or description ilike '%UI PMT%'
    or description ilike 'NEB WORKFORCE UI'
    or description ilike '%LABOR'
    or description ilike '%UNEMP%')
  and description not ilike '%UI PREPAY PLANS%'



select description, primary_merchant_name
from temp_132.sample
where description ilike '%VDOL%'
limit 25