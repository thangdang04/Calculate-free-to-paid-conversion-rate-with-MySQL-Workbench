# Calculate the fraction of students who convert to paying ones after starting a course on the 365 platform
## Overview
In this project, I will help 365 platform analyze data in a relational database with the goal of estimating the free-to-paid conversion rate among students who’ve engaged with video content on the 365 platform. Moreover, I will also calculate several other key metrics to come up with some interpretations.
## Goals
1. Calculate the free-to-paid conversion rate of students who have watched a lecture on the 365 platform.
2. Calculate the average duration between the registration date and when a student has watched a lecture for the first time.
3. Calculate the average duration between the date of first-time engagement and when a student purchases a subscription for the first time.
4. Provide some interpretations and implications.
## Milestones
### 1. Create the subquery:
- Join the tables to create a new result dataset comprising the following columns:
  - student_id – (int) the unique identification of a student.
  - date_registered – (date) the date on which the student registered on the 365 platform.
  - first_date_watched – (date) the date of the first engagement.
  - first_date_purchased – (date) the date of first-time purchase (NULL if they have no purchases).
  - date_diff_reg_watch – (int) the difference in days between the registration date and the date of first-time engagement.
  - date_diff_watch_purch – (int) the difference in days between the date of first-time engagement and the date of first-time purchase (NULL if they have no purchases).

```sql
FROM 
student_info AS si
LEFT JOIN 
student_engagement AS se ON si.student_id=se.student_id
LEFT JOIN 
student_purchases AS sp ON si.student_id=sp.student_id
```

![image](https://github.com/thangdang04/Calculate-free-to-paid-conversion-rate-with-MySQL-Workbench/assets/171898627/a2c67441-a3d3-4ca2-ac48-2e8609d7c7d8)

=> The resulting set includes the student IDs of students entering the above diagram’s shaded region.

- Retrieve the columns one by one.
```sql
SELECT 
si.student_id, si.date_registered, 
MIN(date_watched) AS first_date_watched, 
MIN(date_purchased) AS first_date_purchased, 
DATEDIFF(MIN(date_watched), date_registered) AS date_diff_reg_watch, 
DATEDIFF(MIN(date_purchased), MIN(date_watched)) AS date_diff_watch_purch
```
- Applying the MIN aggregate function in the previous step requires grouping the results.
```sql
GROUP BY si.student_id
```
- Filter the data to exclude the records where the date of first-time engagement comes later than the date of first-time purchase, while keeping the students who have never made a purchase.
```sql
HAVING COALESCE((MIN(date_purchased)), MIN(date_watched)) >= MIN(date_watched)
```
=> Project's query:
```sql
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
```
### 2. Create the main query:
- Surround the created subquery in the previous part (Create the subquery) in parentheses and give it an alias, say subtable.
```sql
FROM (
SELECT 
...
FROM 
...
GROUP BY
...
HAVING
...
) AS subtable
```
- Calculate the free-to-paid conversion rate:

  - This metric measures the proportion of engaged students who choose to benefit from full course access on the 365 platform by purchasing a subscription after watching a lecture. It is calculated as the ratio between:
    - The number of students who watched a lecture and purchased a subscription on the same day or later.

    - The total number of students who have watched a lecture.
  - The result is converted to percentages and the field is called conversion_rate.
```sql
ROUND(COUNT(first_date_purchased)/COUNT(first_date_watched)*100, 2) AS conversion_rate
```
- Calculate the average duration between the registration date and the date of first-time engagement:

  - This metric measures the average duration between the date of registration and the date of first-time engagement. This will tell us how long it takes, on average, for a student to watch a lecture after registration. The metric is calculated by finding the ratio between:
    - The sum of all such durations.

    - The count of these durations, or alternatively, the number of students who have watched a lecture.
  - The field is called av_reg_watch.
```sql
ROUND(SUM(date_diff_reg_watch)/COUNT(date_diff_reg_watch), 2) AS av_reg_watch
```
- Calculate the average duration between the date of first-time engagement and the date of first-time purchase:

  - This metric measures the average time it takes individuals to subscribe to the platform after viewing a lecture. It is calculated by dividing:
    - The sum of all such durations.

    - The count of these durations, or alternatively, the number of students who have made a purchase.
  - The field is called av_watch_purch.
```sql
ROUND(SUM(date_diff_watch_purch)/COUNT(date_diff_watch_purch), 2) AS av_watch_purch
```
=> Project's query:
```sql
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
```
## Interpretations
### 1. Free-to-paid conversion rate:
- Approximately 11% of students who watch a lecture purchase monthly, quarterly, or yearly subscriptions. For example, just about 11 out of every 100 students that visit the 365 platform end up purchasing a subscription, which is a relatively low number.

- Firstly, even if a significant number of students register on the platform, they aren't encouraged to take full advantage of the program and seldom purchase subscriptions. The platform aims for a wider audience instead of data science enthusiasts who are excited to start their career in the industry, which might be one aspect leading to this.

- Secondly, since the platform targets novice audiences, students might want guidance on where to begin.  Should they initially devote several weeks to learning how to use an object-oriented programming language like Python, a query language such as SQL, or a data visualization software like Tableau? What prerequisites are necessary for each of these tools? A personalized learning path for users will definitely help them know exactly where to start and how to continue.

- Thirdly, it may take longer for certain users to embark on a data science journey. For example, they might be working people who are unable to commit the necessary time, or they could be college students whose test periods have just begun.

- Finally, some users might not be fond of the platform and choose to begin their data science journey elsewhere.
### 2. Average duration between registration date and date of first-time engagement:
- On average, it takes students between three and four days to start watching a lecture after registering on the platform. Ideally, it would be great if a new student started watching a lecture on their first day. Every other element that the platform offers (exams, projects, career tracks) requires more attention, while the lessons should be easier to check out.
### 3. Average duration between date of first-time engagement and date of first-time purchase:
- On average, it takes students roughly 24 days to purchase a subscription after familiarizing themselves with the product.
