--Витрина модели атрибуции LAST PEID CLICK
with tab as (
    select
        visitor_id,
        max(visit_date) as dt
    from sessions
    where medium != 'organic'
    group by visitor_id
)

select
    s.visitor_id,
    s.visit_date,
    s.source as utm_source,
    s.medium as utm_medium,
    s.campaign as utm_campaign,
    l.lead_id,
    l.created_at,
    l.amount,
    l.closing_reason,
    l.status_id
from sessions as s
inner join tab
    on
        s.visitor_id = tab.visitor_id
        and s.visit_date = tab.dt
left join leads as l
    on
        s.visitor_id = l.visitor_id
        and s.visit_date <= l.created_at
order by
    l.amount desc nulls last,
    s.visit_date asc,
    utm_source asc,
    utm_medium asc,
    utm_campaign asc
