SELECT 
ROUND(COUNT(first_date_purchased)/COUNT(first_date_watched)*100, 2) AS conversion_rate,
ROUND(SUM(date_diff_reg_watch)/COUNT(date_diff_reg_watch), 2) AS av_reg_watch, 
ROUND(SUM(date_diff_watch_purch)/COUNT(date_diff_watch_purch), 2) AS av_watch_purch
FROM (
SELECT 
si.student_id, si.date_registered, 
MIN(date_watched) AS first_date_watched, 
MIN(date_purchased) AS first_date_purchased, 
DATEDIFF(MIN(date_watched), date_registered) AS date_diff_reg_watch, 
DATEDIFF(MIN(date_purchased), MIN(date_watched)) AS date_diff_watch_purch
FROM 
student_info AS si
LEFT JOIN 
student_engagement AS se ON si.student_id=se.student_id
LEFT JOIN 
student_purchases AS sp ON si.student_id=sp.student_id
GROUP BY si.student_id
HAVING COALESCE((MIN(date_purchased)), MIN(date_watched)) >= MIN(date_watched)
) AS subtable