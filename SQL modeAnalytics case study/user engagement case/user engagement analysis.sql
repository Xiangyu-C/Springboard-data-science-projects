--first check each table to see what kind of data they contain
select * from tutorial.yammer_users 
limit 5

--check another table
--first check each table to see what kind of data they contain
select * from tutorial.yammer_events 
limit 5

--first check to see if new user sign up drops after 2014-07-28
select date_trunc('week', created_at),
count(*) as new_user_signup
from 
(select * from tutorial.yammer_users 
where created_at > '2014-07-28') as sub
group by 1
order by 1

--new user sign up even slightly goes up near the end, so it's
--the existing users that reduced activity. To view existing user 
--activity, we can group them by their registration date
SELECT DATE_TRUNC('week',z.occurred_at) AS "week",
       AVG(z.age_at_event) AS "Average age during week",
       COUNT(DISTINCT CASE WHEN z.user_age > 70 THEN z.user_id ELSE NULL END) AS "10+ weeks",
       COUNT(DISTINCT CASE WHEN z.user_age < 70 AND z.user_age >= 63 THEN z.user_id ELSE NULL END) AS "9 weeks",
       COUNT(DISTINCT CASE WHEN z.user_age < 63 AND z.user_age >= 56 THEN z.user_id ELSE NULL END) AS "8 weeks",
       COUNT(DISTINCT CASE WHEN z.user_age < 56 AND z.user_age >= 49 THEN z.user_id ELSE NULL END) AS "7 weeks",
       COUNT(DISTINCT CASE WHEN z.user_age < 49 AND z.user_age >= 42 THEN z.user_id ELSE NULL END) AS "6 weeks",
       COUNT(DISTINCT CASE WHEN z.user_age < 42 AND z.user_age >= 35 THEN z.user_id ELSE NULL END) AS "5 weeks",
       COUNT(DISTINCT CASE WHEN z.user_age < 35 AND z.user_age >= 28 THEN z.user_id ELSE NULL END) AS "4 weeks",
       COUNT(DISTINCT CASE WHEN z.user_age < 28 AND z.user_age >= 21 THEN z.user_id ELSE NULL END) AS "3 weeks",
       COUNT(DISTINCT CASE WHEN z.user_age < 21 AND z.user_age >= 14 THEN z.user_id ELSE NULL END) AS "2 weeks",
       COUNT(DISTINCT CASE WHEN z.user_age < 14 AND z.user_age >= 7 THEN z.user_id ELSE NULL END) AS "1 week",
       COUNT(DISTINCT CASE WHEN z.user_age < 7 THEN z.user_id ELSE NULL END) AS "Less than a week"
  FROM (
        SELECT events.occurred_at,
               users.user_id,
               DATE_TRUNC('week',users.activated_at) AS activation_week,
               EXTRACT('day' FROM events.occurred_at - users.activated_at) AS age_at_event,
               EXTRACT('day' FROM '2014-09-01'::TIMESTAMP - users.activated_at) AS user_age
          FROM tutorial.yammer_users users
          JOIN tutorial.yammer_events events
            ON events.user_id = users.user_id
           AND events.event_type = 'engagement'
           AND events.event_name = 'login'
           AND events.occurred_at >= '2014-05-01'
           AND events.occurred_at < '2014-09-01'
         WHERE users.activated_at IS NOT NULL
       ) as z

 GROUP BY 1
 ORDER BY 1

 --It seems like old users (more than 5 weeks old) all reduced activity
--Now check to see what kind of problem they might encouter. If the website is broken,
--then computer users will drop. If mobile app is broken ,then phone or tablet users will drop
SELECT DATE_TRUNC('week', occurred_at) AS week,
       COUNT(DISTINCT e.user_id) AS weekly_active_users,
       COUNT(DISTINCT CASE WHEN e.device IN ('macbook pro','lenovo thinkpad','macbook air','dell inspiron notebook',
          'asus chromebook','dell inspiron desktop','acer aspire notebook','hp pavilion desktop','acer aspire desktop','mac mini')
          THEN e.user_id ELSE NULL END) AS computer,
       COUNT(DISTINCT CASE WHEN e.device IN ('iphone 5','samsung galaxy s4','nexus 5','iphone 5s','iphone 4s','nokia lumia 635',
       'htc one','samsung galaxy note','amazon fire phone') THEN e.user_id ELSE NULL END) AS phone,
        COUNT(DISTINCT CASE WHEN e.device IN ('ipad air','nexus 7','ipad mini','nexus 10','kindle fire','windows surface',
        'samsumg galaxy tablet') THEN e.user_id ELSE NULL END) AS tablet
  FROM tutorial.yammer_events e
 WHERE e.event_type = 'engagement'
   AND e.event_name = 'login'
 GROUP BY 1
 ORDER BY 1

--In particular, the phone user activity dropped a lot. So the problem may be related
--to the phone app. Yammer should contact mobile app team to see if there is a problem

