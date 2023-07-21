
select employer_type, count(distinct unique_mem_id)
from (
select *, case when description similar to '(%IRS TREAS%|%015  TREAS 310%|%RRB%|%TREAS 449%|%SSA%|%VACP%|%SSI%|%VA BEN%|%TREASURY PMN%|' ||
                                        '%TRAVEL%|%SERV F%|%SUPP SEC%|%36   TREAS 310%|%DOEP%|%DFEC%|%SBAD%|%ASI GOV%|%CHILD%)' then null
           when upper(primary_merchant_name) similar to '(%BONNEVILLE POWER ADMINISTRATION%|' ||
                                                         '%UNITED STATES COAST GUARD%|%U.S. DEPARTMENT OF HEALTH AND HUMAN SERVICES%|' ||
                                                         '%FARM SERVICE AGENCY%)' then upper(primary_merchant_name)
           when primary_merchant_name ilike '%GENERAL SERVICES ADMINISTRATION%' or description ilike '%GSA TREAS 310%' then 'GENERAL SERVICES ADMINISTRATION'
           when primary_merchant_name ilike '%CUSTOMS AND BORDER PROTECTION%' or (description ilike '%CBP%' and description ilike '%TREAS 310%') then 'CUSTOMS AND BORDER PROTECTION'
           when primary_merchant_name ilike '%AGRICULTURAL TREASURY OFFICE%' or (description ilike '%AGRI%' and description ilike '%TREAS 310%') then 'AGRICULTURAL TREASURY OFFICE'
           when description ilike '%DOI%' and description ilike '%TREAS 310%' then 'DEPARTMENT OF THE INTERIOR'
           when description ilike '%DOT4%' and description ilike '%TREAS 310%' then 'DEPARTMENT OF TRANSPORTATION'
           when description ilike '%DHS%' and description ilike '%TREAS 310%' then 'DEPARTMENT OF HOMELAND SECURITY'
           when description ilike '%DOS%' and description ilike '%TREAS 310%' then 'DEPARTMENT OF STATE'
           when description ilike '%DOJ%' and description ilike '%TREAS 310%' and description not ilike '%CORPORATE%' then 'DEPARTMENT OF JUSTICE'
           when description ilike '%EPA TREAS 310%' then 'ENVIRONMENTAL PROTECTION AGENCY'
           when description ilike '%FAA TREAS 310%' then 'FEDERAL AVIATION ADMINISTRATION'
           when description ilike '%LOC%' and description ilike '%TREAS 310%' then 'LIBRARY OF CONGRESS'
           when description ilike '%NIH  TREAS 310%' or description ilike '%NIH. TREAS 310%' then 'NATIONAL INSTITUTES OF HEALTH'
           when description ilike '%USSS%' and description ilike '%TREAS 310%' then 'UNITED STATES SECRET SERVICE'
           when description ilike '%TENN VALLEY AUTH%' then 'TENNESSEE VALLEY AUTHORITY'
           when upper(primary_merchant_name) similar to '(%U S TREASURY FMS%|%U.S. DEPARTMENT OF THE TREASURY%|%US TREASURY%)' then 'US TREASURY'
           when description ilike '%DFAS%' and description ilike '%ARMY%' and upper(description) not similar to '(%RET%|%TRAVEL%)' then 'DFAS - ARMY'
           when description ilike '%DFAS%' and description ilike '%AF%' and upper(description) not similar to '(%RET%|%TRAVEL%)' then 'DFAS - AIR FORCE'
           when description ilike '%DFAS%' and description ilike '%NAVY%' and upper(description) not similar to '(%RET%|%TRAVEL%)' then 'DFAS - NAVY'
           when primary_merchant_name ilike '%DFAS%' and upper(description) not similar to '(%RET%|%RES%|%TRAVEL%)' then 'DFAS'
           when description ilike '%US HOUSE OF REP%' or description ilike '%SENATE/HOUSE/COM%' then 'US HOUSE OF REP'
           when primary_merchant_name ilike '%US SENATE%' or upper(description) similar to '(%US SENATE%|%SENATE/HOUSE/COM%|%SENATE RULES COM%)' then 'US SENATE'
           when primary_merchant_name ilike '%AMTRAK%' and description ilike '%PAYMENT%' then 'AMTRAK'
else null end as federal_employer,
       case when upper(primary_merchant_name) similar to '(%INDUSTRIES%|%ECONOMIC%|%REAL%|%ELEC%|%SCHOOL%|%ESTATE%|%JESUS%|%BANK%|%SERVICES%|' ||
                                                         '%LABOR%|%SAFETY%|%WATER%|%HUMAN%|%HOSPIT%|%MEDIC%|%PRISON%|%GOLDEN%|%INTERSTATE%|%ENER%|' ||
                                                         '%MIDSTATE%|%NORTH STATE%|%NURSING%|%CREDIT%|%ART%|%PARKING%|%ALLSTATE%|%VETER%|%AUTO%|%BI STATE%|%BADGER%|%OCEAN%|%FARM%|%MECHAN%|%STATESIDE%)' then null
           when primary_merchant_name ilike '%State of Alabama%' and description similar to '(%Salary%|%PAYROLL%)'
               then 'AL'
           when description ilike '%STATE OF ALASKA%' and description ilike '%PAYROLL%' then 'AK'
           when primary_merchant_name ilike '%STATE OF ARIZONA%' and description ilike '%PAYMENT%' then 'AZ'
           when primary_merchant_name ilike '%STATE OF ARKANSAS%' and description ilike '%DIRECT%' then 'AR'
           when primary_merchant_name ilike '%STATE OF CALIFORNIA%' and description ilike '%PAYROLL%' then 'CA'
           when primary_merchant_name ilike '%STATE OF COLORADO%' and description ilike '%PAYROLL%' and description not ilike '%COLORADO STATE U%' then 'CO'
           when primary_merchant_name ilike '%STATE OF CONNECTICUT%' and description ilike '%PAYROLL%' then 'CT'
           -- DC strings were not super conclusive
           when description ilike '%STATE OF DELAWARE%' and description similar to '(%Salary%|%PAYROLL%)' then 'DE'
           when primary_merchant_name ilike '%STATE OF FLORIDA%' and description ilike '%SALARY%' then 'FL'
           when primary_merchant_name ilike '%STATE OF GEORGIA%' and description ilike '%PAYMENTS%' then 'GA'
            when primary_merchant_name ilike '%STATE OF HAWAII%' and description ilike '%SALARY%' then 'HI'
           when primary_merchant_name ilike '%STATE OF IDAHO%' then 'ID'
           when primary_merchant_name ilike '%STATE OF ILLINOIS%' and description similar to '(%Payroll%|%Deposit%)' and description not similar to '(%Commercial%|%Tax%)' then 'IL'
           when primary_merchant_name ilike '%STATE OF INDIANA%' and description similar to '%PAYROLL%' then 'IN'
           when primary_merchant_name ilike '%STATE OF IOWA%' and description similar to '(%DIRECT%|%Salary%)' then 'IA'
           when primary_merchant_name ilike '%STATE OF KANSAS%' and description similar to '%DIR%' and description similar to '%DEP%' then 'KS'
            -- couldn't find the strings for Kentucky
           when primary_merchant_name ilike '%LOUISIANA GOVERNMENT%' and description similar to '%PAYROLL%' then 'LA'
           when primary_merchant_name ilike '%STATE OF MAINE%' and description similar to '%ACCTSPAY%' then 'ME'
           when primary_merchant_name ilike '%STATE OF MARYLAND%' and description similar to '%PAYROLL%' then 'MD'
           when primary_merchant_name ilike '%COMMONWEALTH OF MASSACHUSETTS%' and description ilike '%TREHREMPL%' and description not similar to '(%SSA%|%DSS%)' then 'MA'
           -- nothing clear from Michigan (all child support or pension)
           when primary_merchant_name ilike '%STATE OF MINNESOTA%' and description ilike '%PAYROLL%' then 'MN'
           -- nothing for Mississippi
           when primary_merchant_name ilike '%State of Missouri%' and description ilike '%PAYROLL%' then 'MO'
           when primary_merchant_name ilike '%STATE OF MONTANA%' and description not ilike '%MT%' then 'MT'
            when primary_merchant_name ilike '%STATE OF NEBRASKA%' and description ilike '%PAYROLL%' then 'NE'
           when primary_merchant_name ilike '%STATE OF NEVADA%' and description ilike '%PAYROLL%' then 'NV'
           when primary_merchant_name ilike '%STATE OF NEW HAMPSHIRE%' and description ilike '%PAYMENT%' then 'NH'
           -- NJ includes a bunch of different things under the same strings. exclude for now
           when primary_merchant_name ilike '%State of New Mexico%' and description ilike '%Direct%' and description not similar to '(%VNDR%)' then 'NM'
           -- unsure about NYS.
           when primary_merchant_name ilike '%New York State%' and upper(description) similar to '(%PAYROLL%|%DEP%)' and upper(primary_merchant_name) not similar to '(%LABOR%|%RETIREMENT%|%THEATRE%)'
           and description not ilike '%THEATRE%' then 'NY'
           when primary_merchant_name ilike '%STATE OF NORTH CAROLINA%' and description ilike '%PAYROLL%' then 'NC'
           when primary_merchant_name ilike '%STATE OF OHIO%' and description ilike '%DEP%' and description not ilike '%BNFT%' then 'OH'
           -- didn't find anything for Oklahoma
           when primary_merchant_name ilike '%OREGON FINANCIAL MANAGEMENT AGENT SERVICES%' then 'OR'
           when primary_merchant_name ilike '%COMMONWEALTH OF PENNSYLVANIA%' and description ilike '%PAYROLL%' then 'PA'
           -- RI not conclusions but there are some strings
           -- Didn't see anything for SC or SD
           when primary_merchant_name ilike '%State of Tennessee%' and description ilike '%DEPOS%' then 'TN'
           -- only found 2 departments for texas
           when primary_merchant_name ilike '%Texas Department of Criminal Justice%' or primary_merchant_name ilike '%Texas Department of Transportation%' then 'TX'
           when primary_merchant_name ilike '%State of UTAH%' and description ilike '%PAYROLL%' then 'UT'
           when primary_merchant_name ilike '%State of VERMONT%' and description ilike '%Salary%' then 'VT'
           -- didn't find anything for VA
           when primary_merchant_name ilike '%State of Wisconsin%' and description ilike '%PAYROLL%' then 'WI'
           when primary_merchant_name ilike '%State of Wyoming%' and description ilike '%PAYROLL%' then 'WY'
           when primary_merchant_name ilike '%Washington State Treasurer%' and description ilike '%PAYROLL%' then 'WA'
           when upper(primary_merchant_name) similar to '(%WEST VIRGINIA STATE AUDITOR%|%WEST VIRGINIA STATE TREASURER%)' and description ilike '%PAYROLL%' then 'WV'
           else NULL end as state_employer,
       case when (upper(primary_merchant_name)  similar to '(%SOUTHERN CALIFORNIA%|%WESTERN UNION%|%HEALTH%|%MEDICAL%|%HOSPITAL%|%STUDENT%|%CREDIT%|%RETIREMENT%|%ENGINEERING%|%COMMERCE%|%BENEFITS%)'
        or upper(description)  similar to '(%WASHINGTON UNIV%|%HEALTH%|%MEDICAL%|%HOSPITAL%|%STUDENT%|%CREDIT%|%RETIREMENT%|%BENEFITS%|%AID%|%REFUND%|%TUITION%|%INVOICE%)') then null
           when upper(primary_merchant_name) similar to '%ARIZONA STATE UNIVERSITY%|%ARKANSAS STATE UNIVERSITY%|%BALL STATE UNIVERSITY%|' ||
                                                      '%BOISE STATE UNIVERSITY%|%BOWLING GREEN STATE UNIVERSITY%|' ||
                                                      '%COLORADO STATE UNIVERSITY%|%DELTA STATE UNIVERSITY%|%DIXIE STATE UNIVERSITY%|' ||
                                                      '%FLORIDA A&M UNIVERSITY%|%FLORIDA STATE UNIVERSITY%|%GEORGIA COLLEGE & STATE UNIVERSITY%|' ||
                                                      '%IDAHO STATE UNIVERSITY%|%INDIANA UNIVERSITY%|%IOWA STATE UNIVERSITY%|%JACKSON STATE UNIVERSITY%|' ||
                                                      '%KENNESAW STATE UNIVERSITY%|%KENT STATE UNIVERSITY%|%MICHIGAN STATE UNIVERSITY%|%MONTANA STATE UNIVERSITY%|' ||
                                                      '%NC STATE UNIVERSITY%|%NEVADA SYSTEM-HIGHER EDUCATION%|%NORTH CAROLINA STATE UNIVERSITY%|' ||
                                                      '%NORTHERN ARIZONA UNIVERSITY%|%OHIO STATE UNIVERSITY%|%OREGON STATE UNIVERSITY%|%PENN STATE UNIVERSITY%|' ||
                                                      '%TEXAS A&M UNIVERSITY%|%TEXAS STATE UNIVERSITY%|%TEXAS TECH UNIVERSITY%|%THE OHIO STATE UNIVERSITY%|' ||
                                                      '%THE UNIVERSITY OF ALABAMA%|%THE UNIVERSITY OF IOWA%|%THE UNIVERSITY OF TEXAS AT AUSTIN%|%U.C. BERKELEY%|' ||
                                                      '%UNIVERSITY OF ALABAMA%|%UNIVERSITY OF ARIZONA%|%UNIVERSITY OF ARKANSAS%|%UNIVERSITY OF CALIFORNIA%|%UNIVERSITY OF DELAWARE%|' ||
                                                      '%UNIVERSITY OF FLORIDA%|%UNIVERSITY OF GEORGIA%|%UNIVERSITY OF HAWAII%|%UNIVERSITY OF IDAHO%|%UNIVERSITY OF ILLINOIS%|%UNIVERSITY OF IOWA%|' ||
                                                      '%UNIVERSITY OF KENTUCKY%|%UNIVERSITY OF MINNESOTA%|%UNIVERSITY OF NEBRASKA%|%UNIVERSITY OF NEW MEXICO%|' ||
                                                      '%UNIVERSITY OF OREGON%|%UNIVERSITY OF TEXAS%|%UNIVERSITY OF UTAH%|%UNIVERSITY OF WISCONSIN%|' ||
                                                      '%UNIVERSITY SYSTEM OF GEORGIA%|%UNIVERSITY SYSTEM OF NEW HAMPSHIRE%|%UNIVERSITY OF COLORADO%|' ||
                                                      '%UNIVERSITY OF MASSACHUSETTS%|%UNIVERSITY OF MICHIGAN%|%UNIVERSITY OF MISSOURI%|%UNIVERSITY OF NORTH CAROLINA%|%UNIVERSITY OF SOUTH CAROLINA%|' ||
                                                      '%UTAH STATE UNIVERSITY%|%WASHINGTON STATE UNIVERSITY%|%WAYNE STATE UNIVERSITY%|%WEBER STATE UNIVERSITY%'  then REGEXP_REPLACE( REGEXP_REPLACE(primary_merchant_name, 'The ', ''), 'of', 'Of')
        when primary_merchant_name ilike '%COLO STATE UNIVERSITY%' then 'Colorado State University'
        when description ilike '%CSU Fullerton%' then 'CSU Fullerton'
        when description ilike '%CSU Long Beach%' then 'CSU Long Beach'
        when description ilike '%CSU%' and description ilike '%Northridge%' then 'CSU Northridge'
        when description ilike '%CSU San Bernardi%' then 'CSU San Bernardino'
        when description ilike '%UC LOS ANGELES%' then 'UC Los Angeles'
        when description ilike '%UC IRVINE%' then 'UC Irvine'
        when description ilike '%UNIV CALIF DAVIS%' then 'UC Davis'
        when description ilike '%UNIV%' and description ilike '%OF MISSOURI%' then 'University Of Missouri'
        when description ilike '%ARIZ STATE UNIV%' then 'Arizona State University'
        when description ilike '%Florida A&M Univ%' then 'Florida A&m University'
        when description ilike '%UNIV%' and description ilike '%ALASKA%' then 'University Of Alaska'
        when description ilike '%UNIV%'  and description ilike '%KENTUCKY%' then 'University Of Kentucky'
        when description ilike '%TEXAS ST. Univ%' then 'Texas State University'
        when description ilike '%University of Delaware%' then 'University Of Delaware'
        when description ilike '%UNIV%' and description ilike '%NEBRASKA%' then 'University Of Nebraska'
        when description ilike '%Wash State University%' then 'Washington State University'
        when description ilike '%texas tech univ%' then 'Texas Tech University'
        when description ilike '%UNIV NORTH TEXAS%' then 'University Of North Texas'
        when description ilike '%UNIV%' and description ilike '%TEXAS%' then 'University Of Texas'
        when description ilike '%ball state univ%' then 'Ball State University'
        when description ilike '%Univ%' and description ilike '%mass%' then 'University Of Massachusetts'
        when description ilike '%Troy state univ%' then 'Troy State University'
        when description ilike '%N.C. State Univ.%' then 'Nc State University'
        when description ilike '%UnivMaryland%' then 'University Of Maryland'
        when description ilike '%MICH STATE UNIV%' then 'Michigan State University'
      else NULL end as public_univ_employer,
    case when upper(primary_merchant_name) similar to '(%PARKING%|%AUTO%|%CENTER%|%MOTORS%|%DINER%|%LIQUOR%|%ELECTRIC%|%GAS%|%BALLY%|%PROPERTIES%|%SOAP%|%CHARM%|' ||
                                               '%CITY & COUNTY%|%CIRCLE THE CITY%|%MENTAL%|%WATER%|%STREET%|%UTILIT%|%OFFICIALCREDIT%|%WATER%|%STORES%|' ||
                                               '%HOSPITAL%|%DOOR%|%TAX%|%FAIR%|%SEWER%|%MUSEUM%|%PLUMBING%|%PETROLEUM%|%COUNTYWIDE%|%CITYWIDE%|%HEALTH%|%POTAWATOMI%|' ||
                                               '%REMC%|%PUD%|%TIRE%|%HOUSING%|%VNA%|%CHILDREN%|%AUTHORITY%|%SERVICE%|%MAIN%|%COMMUNITY%|%COLLEGE%|%COURT%)' then null
    when upper(primary_merchant_name) similar to '(%COUNTY%|%CITY OF%)' and upper(primary_merchant_name) not similar to '(%SCHOOL%|%DISTRICT%|%EDUCATION%)' then primary_merchant_name
        else null end as local_employer,
     case when upper(primary_merchant_name) similar to '(%PARKING%|%AUTO%|%CENTER%|%MOTORS%|%DINER%|%LIQUOR%|%ELECTRIC%|%GAS%|%BALLY%|%PROPERTIES%|%SOAP%|%CHARM%|' ||
                                               '%CITY & COUNTY%|%CIRCLE THE CITY%|%MENTAL%|%WATER%|%STREET%|%UTILIT%|%OFFICIALCREDIT%|%WATER%|%STORES%|' ||
                                               '%HOSPITAL%|%DOOR%|%TAX%|%FAIR%|%SEWER%|%MUSEUM%|%PLUMBING%|%PETROLEUM%|%COUNTYWIDE%|%CITYWIDE%|%HEALTH%|%POTAWATOMI%|' ||
                                               '%REMC%|%PUD%|%TIRE%|%HOUSING%|%VNA%|%CHILDREN%|%AUTHORITY%|%SERVICE%|%MAIN%|%COMMUNITY%|%COLLEGE%|%COURT%)' then null
    when upper(primary_merchant_name) similar to '(%COUNTY%|%CITY OF%)' and upper(primary_merchant_name)  similar to '(%SCHOOL%|%DISTRICT%|%EDUCATION%)' then primary_merchant_name
        else null end as local_educ_employer,
    COALESCE(federal_employer, state_employer, public_univ_employer, local_employer, local_educ_employer) as employer,
    case when federal_employer is not null then 'federal'
        when state_employer is not null then 'state'
        when public_univ_employer is not null then 'public_univ'
        when local_employer is not null then 'local'
        when local_educ_employer is not null then 'local_educ'
        else null end as employer_type
from temp_132.sample
where amount > 500 and
      transaction_base_type = 'credit' and
      employer is not null) sub_sort
group by employer_type






















-- Public University
select primary_merchant_name2, count(distinct unique_mem_id) as count
from (select description, unique_mem_id,
    --case when primary_merchant_name <> '' then primary_merchant_name
    case when upper(primary_merchant_name) similar to '%ARIZONA STATE UNIVERSITY%|%ARKANSAS STATE UNIVERSITY%|%BALL STATE UNIVERSITY%|' ||
                                                      '%BOISE STATE UNIVERSITY%|%BOWLING GREEN STATE UNIVERSITY%|' ||
                                                      '%COLORADO STATE UNIVERSITY%|%DELTA STATE UNIVERSITY%|%DIXIE STATE UNIVERSITY%|' ||
                                                      '%FLORIDA A&M UNIVERSITY%|%FLORIDA STATE UNIVERSITY%|%GEORGIA COLLEGE & STATE UNIVERSITY%|' ||
                                                      '%IDAHO STATE UNIVERSITY%|%INDIANA UNIVERSITY%|%IOWA STATE UNIVERSITY%|%JACKSON STATE UNIVERSITY%|' ||
                                                      '%KENNESAW STATE UNIVERSITY%|%KENT STATE UNIVERSITY%|%MICHIGAN STATE UNIVERSITY%|%MONTANA STATE UNIVERSITY%|' ||
                                                      '%NC STATE UNIVERSITY%|%NEVADA SYSTEM-HIGHER EDUCATION%|%NORTH CAROLINA STATE UNIVERSITY%|' ||
                                                      '%NORTHERN ARIZONA UNIVERSITY%|%OHIO STATE UNIVERSITY%|%OREGON STATE UNIVERSITY%|%PENN STATE UNIVERSITY%|' ||
                                                      '%TEXAS A&M UNIVERSITY%|%TEXAS STATE UNIVERSITY%|%TEXAS TECH UNIVERSITY%|%THE OHIO STATE UNIVERSITY%|' ||
                                                      '%THE UNIVERSITY OF ALABAMA%|%THE UNIVERSITY OF IOWA%|%THE UNIVERSITY OF TEXAS AT AUSTIN%|%U.C. BERKELEY%|' ||
                                                      '%UNIVERSITY OF ALABAMA%|%UNIVERSITY OF ARIZONA%|%UNIVERSITY OF ARKANSAS%|%UNIVERSITY OF CALIFORNIA%|%UNIVERSITY OF DELAWARE%|' ||
                                                      '%UNIVERSITY OF FLORIDA%|%UNIVERSITY OF GEORGIA%|%UNIVERSITY OF HAWAII%|%UNIVERSITY OF IDAHO%|%UNIVERSITY OF ILLINOIS%|%UNIVERSITY OF IOWA%|' ||
                                                      '%UNIVERSITY OF KENTUCKY%|%UNIVERSITY OF MINNESOTA%|%UNIVERSITY OF NEBRASKA%|%UNIVERSITY OF NEW MEXICO%|' ||
                                                      '%UNIVERSITY OF OREGON%|%UNIVERSITY OF TEXAS%|%UNIVERSITY OF UTAH%|%UNIVERSITY OF WISCONSIN%|' ||
                                                      '%UNIVERSITY SYSTEM OF GEORGIA%|%UNIVERSITY SYSTEM OF NEW HAMPSHIRE%|%UNIVERSITY OF COLORADO%|' ||
                                                      '%UNIVERSITY OF MASSACHUSETTS%|%UNIVERSITY OF MICHIGAN%|%UNIVERSITY OF MISSOURI%|%UNIVERSITY OF NORTH CAROLINA%|%UNIVERSITY OF SOUTH CAROLINA%|' ||
                                                      '%UTAH STATE UNIVERSITY%|%WASHINGTON STATE UNIVERSITY%|%WAYNE STATE UNIVERSITY%|%WEBER STATE UNIVERSITY%'  then REGEXP_REPLACE( REGEXP_REPLACE(primary_merchant_name, 'The ', ''), 'of', 'Of')
        when primary_merchant_name ilike '%COLO STATE UNIVERSITY%' then 'Colorado State University'
        when description ilike '%CSU Fullerton%' then 'CSU Fullerton'
        when description ilike '%CSU Long Beach%' then 'CSU Long Beach'
        when description ilike '%CSU%' and description ilike '%Northridge%' then 'CSU Northridge'
        when description ilike '%CSU San Bernardi%' then 'CSU San Bernardino'
        when description ilike '%UC LOS ANGELES%' then 'UC Los Angeles'
        when description ilike '%UC IRVINE%' then 'UC Irvine'
        when description ilike '%UNIV CALIF DAVIS%' then 'UC Davis'
        when description ilike '%UNIV%' and description ilike '%OF MISSOURI%' then 'University Of Missouri'
        when description ilike '%ARIZ STATE UNIV%' then 'Arizona State University'
        when description ilike '%Florida A&M Univ%' then 'Florida A&m University'
        when description ilike '%UNIV%' and description ilike '%ALASKA%' then 'University Of Alaska'
        when description ilike '%UNIV%'  and description ilike '%KENTUCKY%' then 'University Of Kentucky'
        when description ilike '%TEXAS ST. Univ%' then 'Texas State University'
        when description ilike '%University of Delaware%' then 'University Of Delaware'
        when description ilike '%UNIV%' and description ilike '%NEBRASKA%' then 'University Of Nebraska'
        when description ilike '%Wash State University%' then 'Washington State University'
        when description ilike '%texas tech univ%' then 'Texas Tech University'
        when description ilike '%UNIV NORTH TEXAS%' then 'University Of North Texas'
        when description ilike '%UNIV%' and description ilike '%TEXAS%' then 'University Of Texas'
        when description ilike '%ball state univ%' then 'Ball State University'
        when description ilike '%Univ%' and description ilike '%mass%' then 'University Of Massachusetts'
        when description ilike '%Troy state univ%' then 'Troy State University'
        when description ilike '%N.C. State Univ.%' then 'Nc State University'
        when description ilike '%UnivMaryland%' then 'University Of Maryland'
        when description ilike '%MICH STATE UNIV%' then 'Michigan State University'
      else NULL end as primary_merchant_name2
      from temp_132.sample
      where amount > 500
        and transaction_category_name = 'Salary/Regular Income'
        and upper(primary_merchant_name) not similar to '(%SOUTHERN CALIFORNIA%|%WESTERN UNION%|%HEALTH%|%MEDICAL%|%HOSPITAL%|%STUDENT%|%CREDIT%|%RETIREMENT%|%ENGINEERING%|%COMMERCE%|%BENEFITS%)'
        and upper(description) not similar to '(%WASHINGTON UNIV%|%HEALTH%|%MEDICAL%|%HOSPITAL%|%STUDENT%|%CREDIT%|%RETIREMENT%|%BENEFITS%)'
        and primary_merchant_name2 is not null
      ) sub_univ
group by primary_merchant_name2
order by primary_merchant_name2


-- Identify State Payroll
select unique_mem_id, description, transaction_category_name,
       primary_merchant_name,
       case
           when primary_merchant_name ilike '%State of Alabama%' and description similar to '(%Salary%|%PAYROLL%)'
               then 'AL'
           when description ilike '%STATE OF ALASKA%' and description ilike '%PAYROLL%' then 'AK'
           when primary_merchant_name ilike '%STATE OF ARIZONA%' and description ilike '%PAYMENT%' then 'AZ'
           when primary_merchant_name ilike '%STATE OF ARKANSAS%' and description ilike '%DIRECT%' then 'AR'
           when primary_merchant_name ilike '%STATE OF CALIFORNIA%' and description ilike '%PAYROLL%' then 'CA'
           when primary_merchant_name ilike '%STATE OF COLORADO%' and description ilike '%PAYROLL%' and description not ilike '%COLORADO STATE U%' then 'CO'
           when primary_merchant_name ilike '%STATE OF CONNECTICUT%' and description ilike '%PAYROLL%' then 'CT'
           -- DC strings were not super conclusive
           when description ilike '%STATE OF DELAWARE%' and description similar to '(%Salary%|%PAYROLL%)' then 'DE'
           when primary_merchant_name ilike '%STATE OF FLORIDA%' and description ilike '%SALARY%' then 'FL'
           when primary_merchant_name ilike '%STATE OF GEORGIA%' and description ilike '%PAYMENTS%' then 'GA'
            when primary_merchant_name ilike '%STATE OF HAWAII%' and description ilike '%SALARY%' then 'HI'
           when primary_merchant_name ilike '%STATE OF IDAHO%' then 'ID'
           when primary_merchant_name ilike '%STATE OF ILLINOIS%' and description similar to '(%Payroll%|%Deposit%)' and description not similar to '(%Commercial%|%Tax%)' then 'IL'
           when primary_merchant_name ilike '%STATE OF INDIANA%' and description similar to '%PAYROLL%' then 'IN'
           when primary_merchant_name ilike '%STATE OF IOWA%' and description similar to '(%DIRECT%|%Salary%)' then 'IA'
           when primary_merchant_name ilike '%STATE OF KANSAS%' and description similar to '%DIR%' and description similar to '%DEP%' then 'KS'
            -- couldn't find the strings for Kentucky
           when primary_merchant_name ilike '%LOUISIANA GOVERNMENT%' and description similar to '%PAYROLL%' then 'LA'
           when primary_merchant_name ilike '%STATE OF MAINE%' and description similar to '%ACCTSPAY%' then 'ME'
           when primary_merchant_name ilike '%STATE OF MARYLAND%' and description similar to '%PAYROLL%' then 'MD'
           when primary_merchant_name ilike '%COMMONWEALTH OF MASSACHUSETTS%' and description ilike '%TREHREMPL%' and description not similar to '(%SSA%|%DSS%)' then 'MA'
           -- nothing clear from Michigan (all child support or pension)
           when primary_merchant_name ilike '%STATE OF MINNESOTA%' and description ilike '%PAYROLL%' then 'MN'
           -- nothing for Mississippi
           when primary_merchant_name ilike '%State of Missouri%' and description ilike '%PAYROLL%' then 'MO'
           when primary_merchant_name ilike '%STATE OF MONTANA%' and description not ilike '%MT%' then 'MT'
            when primary_merchant_name ilike '%STATE OF NEBRASKA%' and description ilike '%PAYROLL%' then 'NE'
           when primary_merchant_name ilike '%STATE OF NEVADA%' and description ilike '%PAYROLL%' then 'NV'
           when primary_merchant_name ilike '%STATE OF NEW HAMPSHIRE%' and description ilike '%PAYMENT%' then 'NH'
           -- NJ includes a bunch of different things under the same strings. exclude for now
           when primary_merchant_name ilike '%State of New Mexico%' and description ilike '%Direct%' and description not similar to '(%VNDR%)' then 'NM'
           -- unsure about NYS.
           when primary_merchant_name ilike '%New York State%' and upper(description) similar to '(%PAYROLL%|%DEP%)' and upper(primary_merchant_name) not similar to '(%LABOR%|%RETIREMENT%|%THEATRE%)'
           and description not ilike '%THEATRE%' then 'NY'
           when primary_merchant_name ilike '%STATE OF NORTH CAROLINA%' and description ilike '%PAYROLL%' then 'NC'
           when primary_merchant_name ilike '%STATE OF OHIO%' and description ilike '%DEP%' and description not ilike '%BNFT%' then 'OH'
           -- didn't find anything for Oklahoma
           when primary_merchant_name ilike '%OREGON FINANCIAL MANAGEMENT AGENT SERVICES%' then 'OR'
           when primary_merchant_name ilike '%COMMONWEALTH OF PENNSYLVANIA%' and description ilike '%PAYROLL%' then 'PA'
           -- RI not conclusions but there are some strings
           -- Didn't see anything for SC or SD
           when primary_merchant_name ilike '%State of Tennessee%' and description ilike '%DEPOS%' then 'TN'
           -- only found 2 departments for texas
           when primary_merchant_name ilike '%Texas Department of Criminal Justice%' or primary_merchant_name ilike '%Texas Department of Transportation%' then 'TX'
           when primary_merchant_name ilike '%State of UTAH%' and description ilike '%PAYROLL%' then 'UT'
           when primary_merchant_name ilike '%State of VERMONT%' and description ilike '%Salary%' then 'VT'
           -- didn't find anything for VA
           when primary_merchant_name ilike '%State of Wisconsin%' and description ilike '%PAYROLL%' then 'WI'
           when primary_merchant_name ilike '%State of Wyoming%' and description ilike '%PAYROLL%' then 'WY'
           when primary_merchant_name ilike '%Washington State Treasurer%' and description ilike '%PAYROLL%' then 'WA'
           when upper(primary_merchant_name) similar to '(%WEST VIRGINIA STATE AUDITOR%|%WEST VIRGINIA STATE TREASURER%)' and description ilike '%PAYROLL%' then 'WV'
           else NULL end as state_code
from temp_132.sample
where amount > 500

-- Local County and City
select unique_mem_id, description, primary_merchant_name, transaction_category_name
from temp_132.sample
where amount > 500 and
      transaction_base_type = 'credit' and
      (primary_merchant_name ilike '%COUNTY%' or
       primary_merchant_name ilike '%CITY%' or
       primary_merchant_name ilike '%PUBLIC SCHOOL%' or
       primary_merchant_name ilike '%SCHOOL DISTRICT%' or
       description ilike '%COUNTY%' or
       description ilike '%CITY' or
       description ilike '%SCHOOL DISTRICT%')
limit 100



-- federal

select unique_mem_id, description, primary_merchant_name, transaction_category_name,
       case when description similar to '(%IRS TREAS%|%015  TREAS 310%|%RRB%|%TREAS 449%|%SSA%|%VACP%|%SSI%|%VA BEN%|%TREASURY PMN%|' ||
                                        '%TRAVEL%|%SERV F%|%SUPP SEC%|%36   TREAS 310%|%DOEP%|%DFEC%|%SBAD%|%ASI GOV%|%CHILD%)' then null
           when upper(primary_merchant_name) similar to '(%BONNEVILLE POWER ADMINISTRATION%|' ||
                                                         '%UNITED STATES COAST GUARD%|%U.S. DEPARTMENT OF HEALTH AND HUMAN SERVICES%|' ||
                                                         '%FARM SERVICE AGENCY%)' then upper(primary_merchant_name)
           when primary_merchant_name ilike '%GENERAL SERVICES ADMINISTRATION%' or description ilike '%GSA TREAS 310%' then 'GENERAL SERVICES ADMINISTRATION'
           when primary_merchant_name ilike '%CUSTOMS AND BORDER PROTECTION%' or (description ilike '%CBP%' and description ilike '%TREAS 310%') then 'CUSTOMS AND BORDER PROTECTION'
           when primary_merchant_name ilike '%AGRICULTURAL TREASURY OFFICE%' or (description ilike '%AGRI%' and description ilike '%TREAS 310%') then 'AGRICULTURAL TREASURY OFFICE'
           when description ilike '%DOI%' and description ilike '%TREAS 310%' then 'DEPARTMENT OF THE INTERIOR'
           when description ilike '%DOT4%' and description ilike '%TREAS 310%' then 'DEPARTMENT OF TRANSPORTATION'
           when description ilike '%DHS%' and description ilike '%TREAS 310%' then 'DEPARTMENT OF HOMELAND SECURITY'
           when description ilike '%DOS%' and description ilike '%TREAS 310%' then 'DEPARTMENT OF STATE'
           when description ilike '%DOJ%' and description ilike '%TREAS 310%' and description not ilike '%CORPORATE%' then 'DEPARTMENT OF JUSTICE'
           when description ilike '%EPA TREAS 310%' then 'ENVIRONMENTAL PROTECTION AGENCY'
           when description ilike '%FAA TREAS 310%' then 'FEDERAL AVIATION ADMINISTRATION'
           when description ilike '%LOC%' and description ilike '%TREAS 310%' then 'LIBRARY OF CONGRESS'
           when description ilike '%NIH  TREAS 310%' or description ilike '%NIH. TREAS 310%' then 'NATIONAL INSTITUTES OF HEALTH'
           when description ilike '%USSS%' and description ilike '%TREAS 310%' then 'UNITED STATES SECRET SERVICE'
           when description ilike '%TENN VALLEY AUTH%' then 'TENNESSEE VALLEY AUTHORITY'
           when upper(primary_merchant_name) similar to '(%U S TREASURY FMS%|%U.S. DEPARTMENT OF THE TREASURY%|%US TREASURY%)' then 'US TREASURY'
           when description ilike '%DFAS%' and description ilike '%ARMY%' and upper(description) not similar to '(%RET%|%TRAVEL%)' then 'DFAS - ARMY'
           when description ilike '%DFAS%' and description ilike '%AF%' and upper(description) not similar to '(%RET%|%TRAVEL%)' then 'DFAS - AIR FORCE'
           when description ilike '%DFAS%' and description ilike '%NAVY%' and upper(description) not similar to '(%RET%|%TRAVEL%)' then 'DFAS - NAVY'
           when primary_merchant_name ilike '%DFAS%' and upper(description) not similar to '(%RET%|%RES%|%TRAVEL%)' then 'DFAS'
           when description ilike '%US HOUSE OF REP%' or description ilike '%SENATE/HOUSE/COM%' then 'US HOUSE OF REP'
           when primary_merchant_name ilike '%US SENATE%' or upper(description) similar to '(%US SENATE%|%SENATE/HOUSE/COM%|%SENATE RULES COM%)' then 'US SENATE'
           when primary_merchant_name ilike '%AMTRAK%' and description ilike '%PAYMENT%' then 'AMTRAK'
else null end as federal
from temp_132.sample
where amount > 500 and
      transaction_base_type = 'credit' and
      federal is not null
order by federal)
