select unique_mem_id, yr_week,
       SUM(CASE WHEN transaction_base_type = 'credit' THEN 1 ELSE 0 END) as num_credit_transactions,
       SUM(CASE WHEN transaction_base_type = 'debit' THEN 1 ELSE 0 END) as num_debit_transactions,
       SUM(CASE WHEN transaction_base_type = 'credit' THEN amount ELSE 0 END) as total_inflows,
       SUM(CASE WHEN transaction_base_type = 'debit' THEN amount ELSE 0 END) as total_outflows,
       num_credit_transactions + num_debit_transactions as num_transactions,
       SUM(CASE WHEN transaction_category_name = 'Mortgage' THEN amount ELSE 0 END) as mortgage,
       SUM(CASE WHEN transaction_category_name = 'Rent' THEN amount ELSE 0 END) as rent,
       AVG(user_score) as avg_user_score,
       SUM(CASE WHEN transaction_category_name IN ('Retirement Contributions', 'Securities Trades', 'Deposits', 'Savings', 'Transfers') THEN amount ELSE 0 END) as savings,
       SUM(CASE WHEN transaction_category_name = 'Credit Card Payments' THEN amount ELSE 0 END) as credit_card_payment,
       SUM(CASE WHEN transaction_category_name IN ('Mortgage', 'Rent', 'Home Improvement', 'Automotive', 'Transfers') THEN amount ELSE 0 END) as durables,
       SUM(CASE WHEN transaction_category_name IN ('Pet Care', 'Office Expenses', 'Charitable Giving', 'Cable/Satellite/Telecom', 'Personal/Family',
                                                   'Electronics', 'Other', 'Subscriptions', 'Travel', 'Insurance', 'Healthcare', 'ATM/Cash Withdrawals',
                                                   'Groceries', 'Entertainment', 'Restaurants') THEN amount ELSE 0 END) as nondurables,
       SUM(CASE WHEN description ilike '%Overdraft%' THEN 1 ELSE 0 END) as num_overdraft
from(
        select *, CONCAT(date_part(year, optimized_transaction_date),date_part(week, optimized_transaction_date)) as yr_week
        from temp_132.bankhquser_sample
        WHERE unique_mem_id IN (SELECT unique_mem_id FROM temp_132.federalemployees_subsamplesalary
                                                     UNION ALL SELECT unique_mem_id FROM temp_132.stateemployees_subsamplesalary)) sub
GROUP BY unique_mem_id, yr_week



