-- Simple Count for Total Population
select count(distinct unique_mem_id) as num_users
from yi_xpanelov6_20220816.bank_panel

-- Count By Month (saved to count_by_month.csv)
select count(distinct unique_mem_id) as num_users, count(*) as num_transactions, month
from (select substring(optimized_transaction_date, 1, 7) as month, unique_mem_id
      from yi_xpanelov6_20220816.bank_panel) as month_create
GROUP BY month
ORDER BY month

-- Checking if IDs are truly random. They are
select count(*), enddigits
from (select mod(unique_mem_id, 100) as enddigits from yi_xpanelov6_20220816.bank_panel)
GROUP BY enddigits
ORDER BY enddigits

-- Create 1% sample and store in my temp directory
CREATE TABLE temp_132.onepercsample AS (SELECT *
                                        FROM yi_xpanelov6_20220816.bank_panel
                                        WHERE mod(unique_mem_id, 100) = 1
                                          AND optimized_transaction_date >= '2018-08-01')

-- Create 1% card sample and store in temp directory
CREATE TABLE temp_132.onepercsample_card AS (SELECT *
                                        FROM yi_xpanelov6_20220816.card_panel
                                        WHERE mod(unique_mem_id, 100) = 1
                                          AND optimized_transaction_date >= '2018-08-01')


-- Count Users/Transactions in the 1% sample
select count(distinct unique_mem_id) as num_users,
       count(distinct unique_bank_account_id),
       count(*)                      as num_transactions
from temp_132.onepercsample

-- User Score Dist (saved to user_score_dist.csv)
select unique_mem_id, avg(user_score), min(user_score), max(user_score), count(*)
from temp_132.onepercsample
where optimized_transaction_date >= '2020-01-01'
  AND optimized_transaction_date < '2020-02-01'
group by unique_mem_id


-- Filter By User Score
-- NB: Next round of filtering uses filter1 as a base table
create table temp_132.filter1 as (SELECT b.*
                                  from (select unique_mem_id,
                                               avg(user_score)                                  as avg,
                                               min(user_score)                                  as min,
                                               substring(min(optimized_transaction_date), 1, 7) as min_month,
                                               substring(max(optimized_transaction_date), 1, 7) as max_month
                                        from temp_132.onepercsample
                                        group by unique_mem_id) a
                                           inner join temp_132.onepercsample b
                                                      on a.unique_mem_id = b.unique_mem_id
                                  where avg > 6.5)


select count(distinct unique_mem_id)
from temp_132.filter1


-- Find all Qualifying Federal/State/Local Payroll Transactions
create table temp_132.payroll as (
select *
from (select *,
             CASE
                 WHEN ((upper(primary_merchant_name) like '%DFAS%' OR
                        upper(primary_merchant_name) like '%U.S. DEPARTMENT OF THE TREASURY%' OR
                        upper(primary_merchant_name) like '%US TREASURY%' OR
                        upper(primary_merchant_name) like '%GOVERNMENT%' OR
                        upper(primary_merchant_name) like '%GSA%' OR
                        upper(primary_merchant_name) like '%THE GENERAL SERVICES ADMINISTRATION%' OR
                        upper(primary_merchant_name) like '%THE U.S. OFFICE OF PERSONNEL MANAGEMENT%' OR
                        upper(primary_merchant_name) like '%UNITED STATES COAST GUARD%' OR
                        upper(primary_merchant_name) like '%U.S. DEPARTMENT OF HEALTH AND HUMAN SERVICES' OR
                        upper(primary_merchant_name) like '%AGRICULTURAL TREASURY OFFICE%' OR
                        upper(primary_merchant_name) like '%CENSUS%' OR
                        upper(primary_merchant_name) like '%SOCIAL SECURITY ADMINISTRATION%' OR
                        upper(primary_merchant_name) like '%FARM SERVICE AGENCY%' OR
                        description ilike '%FED SAL%'
                     or description ilike '%FAA TREAS 310%'
                     or description ilike '%EPA TREAS 310%'
                     or description ilike '%GSA TREAS 310%'
                     or description ilike '%DOI1 TREAS 310%'
                     or description ilike '%DOT4 TREAS 310%'
                     or description ilike '%NIH  TREAS 310%' or description ilike '%NIH. TREAS 310%'
                     or description ilike '%OPM1 TREAS 310%'
                     or description ilike '%DHS  TREAS 310%'
                     or description ilike '%LOC1 TREAS 310%'
                     or description ilike '%USSS TREAS 310%'
                     or description ilike '%CBP  TREAS 310%'
                     or description ilike '%DOJ  TREAS 310%'
                     or description ilike '%USSS TREAS 310%'
                     or description ilike '%US HOUSE OF REPR%'
                     or description ilike '%US SENATE FED SAL%'
                     or description ilike '%TENN VALLEY AUTH TRPDFEDSL%'
                     or description ilike '%TENN VALLEY AUTH ACH: TRPDFEDSL%'
                     or description ilike '%US SENATE FED SAL%'
                     or description ilike '%USPS%'
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
                     AND primary_merchant_name not ilike '%USPS%'
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
                        upper(primary_merchant_name) like '%STATEOF%' or
                        upper(primary_merchant_name) like '%STATE OF%' or
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
                 WHEN ((upper(primary_merchant_name) like '%COUNTY OF%' or
                        upper(primary_merchant_name) like '%COUNTY%' or
                        upper(primary_merchant_name) like '%CITY OF%' or
                        upper(primary_merchant_name) like '%DEPARTMENT OF%' or
                        upper(primary_merchant_name) like '%CITY DEPARTMENT%' or
                        upper(primary_merchant_name) like 'PUBLIC SCHOOLS')
                     and description not ilike '%TAX%'
                     and description not ilike '%UI%'
                     and description not ilike '%DSS%'
                     and description not ilike '%UNEMP%'
                     and description not ilike '%REFUND%'
                     and description not ilike '%BENEFIT%'
                     and description not ilike '%CHILD%'
                     and upper(primary_merchant_name) not like '%U.S. DEPARTMENT OF THE TREASURY%'
                     and upper(primary_merchant_name) not like '%US DEPARTMENT OF EDUCATION%'
                     and upper(primary_merchant_name) not like '%U.S. DEPARTMENT OF HEALTH AND HUMAN SERVICES%'
                     and upper(primary_merchant_name) not like '%US TREASURY%'
                     and upper(primary_merchant_name) not like '%DEPARTMENT OF VETERAN AFFAIRS%'
                     and upper(primary_merchant_name) not like '%DEPARTMENT OF VETERANS AFFAIRS%'
                     and upper(primary_merchant_name) not like '%ELECTRIC%'
                     and upper(primary_merchant_name) not like '%GAS%'
                     and upper(primary_merchant_name) not like '%UTILIT%'
                     and upper(primary_merchant_name) not like '%Prince William County Service Authority%'
                     and upper(primary_merchant_name) not like '%UNIVERSITY%'
                     and upper(primary_merchant_name) not like '%HOSPITAL%'
                     and upper(primary_merchant_name) not like '%RETIR%'
                     and upper(primary_merchant_name) not like '%REVENUE%') THEN 'local'
                 ELSE 'other' END as fed
      from temp_132.filter1
      where transaction_base_type = 'credit'
        and transaction_category_name = 'Salary/Regular Income'
        and amount > 500
        and is_duplicate = 0)
where fed not like 'other')

create table temp_132.payroll_ids as (
select distinct unique_mem_id
from temp_132.payroll
where fed <> 'other')



