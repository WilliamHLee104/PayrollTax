create table temp_132.oneperc_combo as(
(select a.unique_mem_id, a.optimized_transaction_date, a.transaction_base_type, a.transaction_category_name,
                             a.amount, 'bank' as source
from temp_132.onepercsample a inner join temp_132.payroll_ids b
on a.unique_mem_id = b.unique_mem_id)
UNION ALL
(select a.unique_mem_id,
        a.optimized_transaction_date,
        a.transaction_base_type,
        a.transaction_category_name,
        a.amount,
        'card' as source
 from temp_132.onepercsample_card a
          inner join temp_132.payroll_ids b on a.unique_mem_id = b.unique_mem_id))

create table temp_132.user_history as (
select a.*
from (select unique_mem_id, min(optimized_transaction_date) as min_date,
             max(optimized_transaction_date) as max_date, count(*) as n_transactions
from yi_xpanelov6_20220816.bank_panel
where mod(unique_mem_id,100) = 1
group by unique_mem_id) a
inner join temp_132.payroll_ids b
on a.unique_mem_id = b.unique_mem_id)


select unique_mem_id, yr_week, transaction_base_type, transaction_category_name, sum(amount) as category_amt,
       case
           when transaction_category_name in
                ('Deposits', 'Insurance', 'Retirement Contributions', 'Savings', 'Securities Trades', 'Transfers')
               then 'savings/investment'
           when transaction_category_name in ('Automotive/Fuel')
               then 'auto'
           when transaction_category_name in ('Mortgage', 'Rent', 'Home Improvement', 'Utilities')
               then 'housing'
           when transaction_category_name in ('Education')
               then 'education'
           when transaction_category_name in ('Credit Card Payments', 'Loans')
               then 'debtpaydown'
           when transaction_category_name in
                ('ATM/Cash Withdrawals', 'Cable/Satellite/Telecom', 'Charitable Giving',
                 'Electronics/General Merchandise',
                 'Entertainment/Recreation', 'Gifts', 'Groceries', 'Healthcare/Medical', 'Insurance', 'Office Expenses',
                 'Personal/Family', 'Pet Care', 'Postage/Shipping',
                 'Restaurants', 'Rewards', 'Services/Supplies', 'Subscriptions', 'Travel')
               then 'nondurables'
           else 'other' end                                                         as agg_category
from  (select *, CONCAT(date_part(year, optimized_transaction_date),date_part(week, optimized_transaction_date)) as yr_week
        from temp_132.oneperc_combo)
group by unique_mem_id, yr_week, transaction_base_type, transaction_category_name

