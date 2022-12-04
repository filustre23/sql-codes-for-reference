 -- code to create a time series models -- 

select 
a.date::date as reporting_date,
date_diff('d',b.date_hired,a.date) as days_since_hired,
case when b.date_started is not null and a.date::date >= b.date_started::date then 1 else 0 end as active_flag,
case when b.date_termed is not null and a.date::date >= b.date_termed::date then 1 else 0 end as inactive_flag
from {{ source('schema', 'calendar') }} a, {{ source('schema', 'start_term_date_table')}} b
where a.date::date >= b.date_hired::date and
      a.date::date < getdate()::date
