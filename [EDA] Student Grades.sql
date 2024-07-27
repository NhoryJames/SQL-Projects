-- 1. Showing all rows inside student_info
SELECT *
FROM student_info


-- 2. Showing all rows inside student_scores
SELECT *
FROM student_scores


-- 3. Showing similar rows between student_info and student_scores using INNER JOIN
SELECT *
FROM student_info info
INNER JOIN student_scores score
	ON info.id = score.id


-- 4. Showing the total number of students who has an extracurricular activities and students without one
SELECT extracurricular_activities, COUNT(extracurricular_activities) num_of_students,
CASE 
	WHEN extracurricular_activities = 1 THEN 'w/ extracurricular activity'
	ELSE 'w/o extracurricular activity'
END AS student_act_status
FROM student_info
GROUP BY extracurricular_activities


-- 5. Showing the total number of students who has a part time job and students without a part time job
SELECT part_time_job, COUNT(part_time_job) num_of_students,
CASE 
	WHEN part_time_job = 1 THEN 'w/ part time job'
	ELSE 'w/o part time job'
END AS student_emp_status
FROM student_info
GROUP BY part_time_job

-- 6. Displaying the count of students who passed the exam in biology
SELECT COUNT(biology_score) num_of_passed_students
FROM student_scores
WHERE biology_score BETWEEN 0 AND 74

-- 7. Displaying the count of students who passed the exam in biology
SELECT COUNT(biology_score) num_of_failed_students
FROM student_scores
WHERE biology_score BETWEEN 75 AND 100

-- 6. Displaying the total number of students who got the highest score in biology
SELECT biology_score, COUNT(*) num_of_students 
FROM student_scores
WHERE biology_score = (SELECT MAX(biology_score) FROM student_scores)
GROUP BY biology_score


-- 7. Displaying the total number of students who got the lowest score in biology
SELECT biology_score, COUNT(*) num_of_students 
FROM student_scores
WHERE biology_score = (SELECT MIN(biology_score) FROM student_scores)
GROUP BY biology_score


-- 8. Displaying the list of students who achieved a passing score of 75 or higher on every subject exam.
SELECT CONCAT(first_name, ' ', last_name) stud_name, biology_score, chemistry_score, english_score, geography_score, history_score, math_score, physics_score
FROM student_info info
INNER JOIN student_scores score ON info.id = score.id 
WHERE biology_score >= 75 AND chemistry_score >= 75 AND english_score >= 75 AND geography_score >= 75 AND history_score >= 75 AND math_score >= 75 AND physics_score >= 75
ORDER BY 1 ASC


-- 9. Looking at the total number of students per career aspiration and the percentage of students for each career aspiration out of the total number of students 
SELECT 
    career_aspiration, 
    COUNT(career_aspiration) num_of_student, 
    (COUNT(career_aspiration) * 100.0 / SUM(COUNT(career_aspiration)) OVER ()) total_percentage
FROM student_info
GROUP BY career_aspiration
ORDER BY num_of_student DESC;


-- 10. Looking at the total scores of each students and their overall performance percentage. This also shows the top performing students.
WITH student_performance AS(
SELECT score.id,
	math_score + physics_score + chemistry_score + biology_score + english_score + geography_score + history_score as total_score, 
	(CAST(math_score AS FLOAT) + physics_score + chemistry_score + biology_score + english_score + geography_score + history_score) / 700 * 100 AS overall_percentage
FROM student_scores score
FULL JOIN student_info info 
	ON info.id = score.id)
SELECT CONCAT(first_name, ' ', last_name) stud_name, overall_percentage, total_score, RANK() OVER (ORDER BY total_score DESC) rank
FROM student_info info
INNER JOIN student_performance perf
	ON info.id = perf.id
ORDER BY total_score DESC


-- 11. Displaying the list of students who achieved a passing score of 75% and the students eligible for admission.
SELECT CONCAT(first_name, ' ', last_name) stud_name,
    score.math_score + score.physics_score + score.chemistry_score + score.biology_score + score.english_score + score.geography_score + score.history_score AS total_score, 
    ((CAST(score.math_score AS FLOAT) + score.physics_score + score.chemistry_score + score.biology_score + score.english_score + score.geography_score + score.history_score) / 700) * 100 AS overall_percentage
FROM student_scores score 
INNER JOIN student_info info ON info.id = score.id 
WHERE ((CAST(score.math_score AS FLOAT) + score.physics_score + score.chemistry_score + score.biology_score + score.english_score + score.geography_score + score.history_score) / 700) * 100 >= 75
ORDER BY overall_percentage DESC;


-- 12. Showing the overall score percentage for every career aspiration on the dataset
SELECT career_aspiration,
	AVG((CAST(math_score AS FLOAT) + physics_score + chemistry_score + biology_score + english_score + geography_score + history_score) / 700 * 100) as score_percentage
FROM student_info info
INNER JOIN student_scores score
	ON info.id = score.id
GROUP BY career_aspiration
ORDER BY score_percentage DESC


-- 13. Showing the average test score per subject of every career aspiration
SELECT career_aspiration,
	AVG(biology_score) avg_biology_score,
	AVG(chemistry_score) avg_chemistry_score,
	AVG(english_score) avg_english_score,
	AVG(geography_score) avg_geography_score,
	AVG(history_score) avg_history_score,
	AVG(math_score) avg_math_score,
	AVG(physics_score) avg_physics_score
FROM student_info info
INNER JOIN student_scores score
	ON info.id = score.id
GROUP BY career_aspiration


-- 14. Showing the average test score per subject of every number of absents on the dataset
SELECT absence_days,
	AVG(biology_score) avg_biology_score,
	AVG(chemistry_score) avg_chemistry_score,
	AVG(english_score) avg_english_score,
	AVG(geography_score) avg_geography_score,
	AVG(history_score) avg_history_score,
	AVG(math_score) avg_math_score,
	AVG(physics_score) avg_physics_score
FROM student_info info
INNER JOIN student_scores score
	ON info.id = score.id
GROUP BY absence_days
ORDER BY absence_days DESC


-- 15. Showing the average scores of students with/out part time job and extracurricular activies
SELECT part_time_job, extracurricular_activities, COUNT(part_time_job) num_of_students,
	AVG(biology_score) avg_biology_score,
	AVG(chemistry_score) avg_chemistry_score,
	AVG(english_score) avg_english_score,
	AVG(geography_score) avg_geography_score,
	AVG(history_score) avg_history_score,
	AVG(math_score) avg_math_score,
	AVG(physics_score) avg_physics_score
FROM student_info info
INNER JOIN student_scores score
	ON info.id = score.id
GROUP BY part_time_job, extracurricular_activities


-- 16. A stored procedure that shows the average scores of students who have a weekly self study hours equals to a specified user input.
--CREATE PROCEDURE AvgStudScoresByStudyHours @weekly_self_study_hours int
--AS
SELECT weekly_self_study_hours, COUNT(weekly_self_study_hours) num_of_students, 
	AVG(biology_score) avg_biology_score,
	AVG(chemistry_score) avg_chemistry_score,
	AVG(english_score) avg_english_score,
	AVG(geography_score) avg_geography_score,
	AVG(history_score) avg_history_score,
	AVG(math_score) avg_math_score,
	AVG(physics_score) avg_physics_score
FROM student_info info
INNER JOIN student_scores score
	ON info.id = score.id
--WHERE weekly_self_study_hours = @weekly_self_study_hours
GROUP BY weekly_self_study_hours
ORDER BY weekly_self_study_hours DESC

EXEC AvgStudScoresByStudyHours @weekly_self_study_hours = 10


-- 17.  A stored procedure with multiple parameters that shows the average scores of students with/out part time job and extracurricular activies and their weekly_self_study_hours
--CREATE PROCEDURE GetStudPerfByActivityJobAndSelfStudyHours @weekly_self_study_hours int, @part_time_job bit, @extracurricular_activities bit
--AS
SELECT part_time_job, extracurricular_activities, weekly_self_study_hours, COUNT(*) num_of_students,
	AVG((CAST(math_score AS FLOAT) + physics_score + chemistry_score + biology_score + english_score + geography_score + history_score) / 700 * 100) as score_percentage
FROM student_info info
INNER JOIN student_scores score
	ON info.id = score.id
--WHERE weekly_self_study_hours = 
--	@weekly_self_study_hours AND part_time_job = @part_time_job AND extracurricular_activities = @extracurricular_activities
GROUP BY part_time_job, extracurricular_activities, weekly_self_study_hours
ORDER BY score_percentage DESC

EXEC GetStudPerfByActivityJobAndSelfStudyHours @weekly_self_study_hours = 0, @part_time_job = 0, @extracurricular_activities = 0

-- 18. A temp table containing the average grade per subject in every specified week self study hours
DROP TABLE IF EXISTS #avg_grade_per_self_study_hours
CREATE TABLE #avg_grade_per_self_study_hours(
	study_hours varchar(50),
	avg_biology_score int,
	avg_chemistry_score int,
	avg_english_score int,
	avg_geography_score int,
	avg_history_score int,
	avg_math_score int,
	avg_physics_score int
)

--INSERT INTO #avg_grade_per_self_study_hours (study_hours) 
--VALUES
--	('0-10'),
--	('11-20'),
--	('21-31'),
--	('31-40'),
--	('41-50')

INSERT INTO #avg_grade_per_self_study_hours (avg_biology_score, avg_chemistry_score, avg_english_score, avg_geography_score, avg_history_score, avg_math_score, avg_physics_score) 
SELECT
	AVG(biology_score) avg_biology_score,
	AVG(chemistry_score) avg_chemistry_score,
	AVG(english_score) avg_english_score,
	AVG(geography_score) avg_geography_score,
	AVG(history_score) avg_history_score,
	AVG(math_score) avg_math_score,
	AVG(physics_score) avg_physics_score
FROM student_scores scores INNER JOIN student_info  info ON scores.id = info.id 
WHERE weekly_self_study_hours BETWEEN 11 AND 20

SELECT *
FROM #avg_grade_per_self_study_hours