with tab as (
    select
        visitor_id,
        max(visit_date) as dt
    from sessions
    where medium != 'organic'
    group by visitor_id
),

all_costs as (
    select
        campaign_date,
        utm_source,
        utm_medium,
        utm_campaign,
        utm_content,
        sum(daily_spent) as daily_spent
    from vk_ads
    group by campaign_date, utm_source, utm_medium, utm_campaign, utm_content
    union all
    select
        campaign_date,
        utm_source,
        utm_medium,
        utm_campaign,
        utm_content,
        sum(daily_spent) as daily_spent
    from ya_ads
    group by campaign_date, utm_source, utm_medium, utm_campaign, utm_content
)

select
    s.source as utm_source,
    s.medium as utm_medium,
    s.campaign as utm_campaign,
    date_trunc('day', s.visit_date) as visit_date,
    count(s.visitor_id) as visitors_count,
    sum(distinct ac.daily_spent) as total_cost,
    count(l.lead_id) as leads_count,
    count(l.lead_id) filter (
        where l.closing_reason = 'Успешная продажа' or l.status_id = 142
    ) as purchases_count,
    sum(l.amount) filter (
        where l.closing_reason = 'Успешная продажа' or l.status_id = 142
    ) as revenue
from sessions as s
inner join tab
    on
        s.visitor_id = tab.visitor_id
        and s.visit_date = tab.dt
left join all_costs as ac
    on
        date_trunc('day', s.visit_date) = ac.campaign_date
        and s.source = ac.utm_source
        and s.medium = ac.utm_medium
        and s.campaign = ac.utm_campaign
        and s.content = ac.utm_content
left join leads as l
    on s.visitor_id = l.visitor_id
group by date_trunc('day', s.visit_date), s.source, s.medium, s.campaign
order by
    visit_date asc,
    visitors_count desc,
    utm_source asc,
    utm_medium asc,
    utm_campaign asc,
    revenue desc nulls last
