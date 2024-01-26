SELECT DATE_FORMAT(NOW(), '%Y-%m-%d') AS current_dt;

SELECT DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s') AS current_dttm;

SELECT DATE_ADD(NOW(), INTERVAL 1 DAY ) AS tomorrow;

SELECT DATE_ADD(NOW(), INTERVAL -1 DAY ) AS yesterday;

SELECT RPAD('Clone', 10, '_');
SELECT LPAD('Clone', 10, '_');
SELECT RTRIM('Clone       ');

SELECT CONCAT('Georgi ', 'Christian') as name;

SELECT CONCAT('Georgi', 'Christian', CAST(2 AS CHAR)) AS name;

SELECT GROUP_CONCAT(dept_no) FROM departments;

SELECT GROUP_CONCAT(dept_no SEPARATOR '|') FROM departments;

SELECT GROUP_CONCAT(dept_no ORDER BY emp_no DESC)
		FROM dept_emp
        WHERE emp_no BETWEEN 10001 and 10003;
        
        
 -- 윈도우 함수를 이용해 최대 5개 부서만 GROUP_CONCAT 실행
SELECT GROUP_CONCAT(dept_no ORDER BY dept_name DESC)
		FROM(
        SELECT *, RANK() OVER (ORDER BY dept_no) AS rnk
        FROM departments
        ) as x
        WHERE rnk >= 5;
        
 -- // 레터럴 조인을 이용해 부서별로 10명씩만 GROUP_CONCAT 실행
 SELECT d.dept_no, GROUP_CONCAT(de2.emp_no)
		FROM departments d
 LEFT JOIN LATERAL (SELECT de.dept_no, de.emp_no
					FROM dept_emp de
                    WHERE de.dept_no = d.dept_no
                    ORDER BY de.emp_no ASC LIMIT 10) de2 ON de2.dept_no=d.dept_no
 GROUP BY d.dept_no;
 

SELECT emp_no, first_name,
  CASE gender WHEN 'M' THEN 'Man'
			  WHEN 'F' THEN 'Woman'
              ELSE 'Unknown' END AS gender
  FROM employees
  LIMIT 10;
  
SELECT emp_no, first_name,
	   CASE WHEN hire_date<'1995-01-01' THEN 'Old'
			ELSE 'New' END AS employee_type
  FROM employees
  LIMIT 10;
  
SELECT de.dept_no, e.first_name, e.gender,
		(SELECT s.salary FROM salaries s
         WHERE s.emp_no = e.emp_no
         ORDER BY from_date DESC LIMIT 1) AS last_salary
  FROM dept_emp de, employees e
  WHERE e.emp_no = de.emp_no
		AND de.dept_no='d001';
        
SELECT de.dept_no, e.first_name, e.gender,
		CASE WHEN e.gender='F' THEN
		(SELECT s.salary FROM salaries s
         WHERE s.emp_no = e.emp_no
         ORDER BY from_date DESC LIMIT 1) ELSE 0 END AS last_salary
  FROM dept_emp de, employees e
  WHERE e.emp_no = de.emp_no
		AND de.dept_no='d001';
        
SELECT CAST('1234' AS SIGNED INTEGER) AS converted_integer;
SELECT CAST('2000-01-01' AS DATE) AS converted_date;

SELECT CAST(1-2 AS UNSIGNED);
SELECT 1-2;

SELECT SHA2('1234', 256 );

CREATE TABLE tb_accesslog (
	access_id BIGINT NOT NULL AUTO_INCREMENT,
    access_url VARCHAR(500) NOT NULL,
    access_dttm DATETIME NOT NULL,
    PRIMARY KEY (access_id),
    INDEX ix_accessurl (access_url)
	) ENGINE = INNODB;
    
drop table tb_accesslog;

CREATE TABLE tb_accesslog (
	access_id BIGINT NOT NULL AUTO_INCREMENT,
    access_url VARCHAR(1000) NOT NULL,
    access_dttm DATETIME NOT NULL,
    PRIMARY KEY (access_id),
    INDEX ix_accessurl ((UNHEX(MD5(access_url))))
	) ENGINE = INNODB;
    
INSERT INTO tb_accesslog VALUES (1, 'http://matt.com', NOW());

SELECT * FROM tb_accesslog WHERE MD5(access_url)='http://matt.com';
SELECT * FROM tb_accesslog WHERE MD5(access_url)=MD5('http://matt.com');

EXPLAIN SELECT * FROM tb_accesslog WHERE MD5(access_url)=MD5('http://matt.com');

SELECT SLEEP(1.5)
  FROM employees
 WHERE emp_no BETWEEN 10001 AND 10010;
 
 SELECT JSON_PRETTY(doc) FROM employee_docs WHERE emp_no=10005;
 
SELECT emp_no, cnt
FROM (
SELECT s.emp_no, COUNT(DISTINCT e.first_name) AS cnt, MAX(s.salary) as max_salary
FROM salaries s
  INNER JOIN employees e On e.emp_no=s.emp_no
WHERE s.emp_no IN(100001, 100002)
GROUP BY s.emp_no
HAVING MAX(s.salary) > 1000
LIMIT 10) temp_view
ORDER BY max_salary;

SELECT * FROM salaries WHERE salary > 150000/10;

SELECT * FROM titles WHERE to_date IS NULL;

EXPLAIN SELECT * FROM employees WHERE first_name=10001;

SELECT COUNT(*)
  FROM employees
 WHERE hire_date>STR_TO_DATE('2011-07-23', '%Y-%m-%d');
 
SELECT COUNT(*)
  FROM employees
 WHERE hire_date>'2011-07-23';

SELECT COUNT(*)
  FROM employees
 WHERE hire_date > DATE(NOW());
 
SELECT count(*) FROM salaries;

SELECT COUNT(*) FROM salaries
 WHERE CONVERT_TZ(from_date, '+00:00', '+09:00')>'1991-01-01';
 
SELECT COUNT(*) FROM salaries
 WHERE to_date < '1985-01-01';
 
SELECT COUNT(*) FROM salaries
WHERE CONVERT_TZ(from_date, '+00:00', '+09:00')>'1991-01-01'
  AND to_date < '1985-01-01';  
 
SELECT COUNT(*) FROM salaries
WHERE to_date < '1985-01-01'
  AND CONVERT_TZ(from_date, '+00:00', '+09:00')>'1991-01-01';  
  
SELECT * FROm employees
 WHERE last_name='Aamodt'
   AND first_name='Matt';
   
SELECT * FROm employees
 WHERE last_name='Aamodt'
   AND first_name='Matt'
   AND MONTH(birth_date)=1;
   
SELECT *
  FROM employees e
 WHERE e.first_name='Matt'
   AND EXISTS (SELECT 1 FROM salaries s
			   WHERE s.emp_no=e.emp_no AND s.to_date>'1995-01-01'
               GROUP BY s.salary HAVING COUNT(*)>1)
   AND e.last_name='Aamodt';
   
FLUSH STATUS;
SELECT *
 FROM employees e
 WHERE e.first_name='Matt'
   AND e.last_name='Aamodt'
   AND EXISTS (SELECT 1 FROM salaries s
			    WHERE s.emp_no=e.emp_no AND s.to_date>'1995-01-01'
                GROUP BY s.salary HAVING COUNT(*)>1);
                
SHOW STATUS LIKE 'Handler_read%';

FLUSH STATUS;

SELECT * FROM employees
 WHERE emp_no BETWEEN 10001 AND 10005
 ORDER BY first_name
 LIMIT 0, 5;
 
 select * from employees limit 0, 10;
SELECT * FROM employees GROUP BY first_name LIMIT 0, 10;
SELECT DISTINCT first_name FROM employees LIMIT 0, 10;

SELECT * FROM employees
 WHERE emp_no BETWEEN 10001 AND 11000
 ORDER BY first_name
 LIMIT 0, 10;
 
SELECT *
  FROM employees e, dept_emp de
 WHERE e.emp_no=de.emp_no;
 
CREATE TABLE tb_test1 (user_id INT, user_type INT, PRIMARY KEY(user_id));
CREATE TABLE tb_test2 (user_type CHAR(1), type_desc VARCHAR(10), PRIMARY KEY(user_type));

SELECT *
  FROM tb_test1 tb1, tb_test2 tb2
 WHERE tb1.user_type=tb2.user_type;
 
SELECT *
  FROM employees e
	LEFT JOIN dept_emp de ON de.emp_no=e.emp_no
    LEFT JOIN departments d ON d.dept_no=de.dept_no AND d.dept_name='Development';
    
SELECT *
  FROM employees e
    LEFT JOIN dept_manager mgr ON mgr.emp_no=e.emp_no AND mgr.dept_no='d001';
    
SELECT *
  FROM employees e
    LEFT JOIN dept_manager dm ON dm.emp_no = e.emp_no AND dm.emp_no IS NULL
    LIMIT 10;
    
SELECT e.*
  FROM salaries s, employees e
 WHERE e.emp_no=s.emp_no
   AND s.emp_no BETWEEN 10001 AND 13000
 GROUP BY s.emp_no
 ORDER BY SUM(s.salary) DESC
 LIMIT 10;
 
EXPLAIN SELECT e.*
  FROM salaries s, employees e
 WHERE e.emp_no=s.emp_no
   AND s.emp_no BETWEEN 10001 AND 13000
 GROUP BY s.emp_no
 ORDER BY SUM(s.salary) DESC
 LIMIT 10;
 
 SELECT e.*
   FROM
	  (SELECT s.emp_no
		 FROM salaries s
		WHERE s.emp_no BETWEEN 10001 AND 13000
		GROUP BY s.emp_no
        ORDER BY SUM(s.salary) DESC
        LIMIT 10) x,
        employees e
	WHERE e.emp_no=x.emp_no;
    
SELECT *
  FROM employees e
    LEFT JOIN LATERAL (SELECT *
						 FROM salaries s
                         WHERE s.emp_no=e.emp_no
                         ORDER BY s.from_date DESC LIMIT 2) s2 ON s2.emp_no=e.emp_no
	WHERE e.first_name='Matt';
    
    
SELECT e.emp_no, e.first_name, e.last_name, de.from_date
  FROM dept_emp de, employees e
 WHERE de.from_date>'2001-10-01' AND e.emp_no<10005;
 
SELECT dept_no, COUNT(*)
  FROM dept_emp
 GROUP BY dept_no WITH ROLLUP;
 
SELECT first_name, last_name, COUNT(*)
  FROM employees
 GROUP BY first_name, last_name WITH ROLLUP;
 
SELECT 
	IF(GROUPING(first_name), 'All first_name', first_name) AS first_name,
    IF(GROUPING(last_name), 'All last_name', last_name) AS last_name,
    COUNT(*)
  FROM employees
  GROUP BY first_name, last_name WITH ROLLUP;
  
SELECT dept_no, COUNT(*) AS emp_count
  FROM dept_emp
  GROUP BY dept_no;
  
ALTER TABLE salaries ADD INDEX ix_salary_fromdate (salary DESC, from_date ASC);

SELECT * FROM salaries
 ORDER BY salary DESC LIMIT 10;
  
  
ALTER TABLE salaries ADD INDEX ix_salary_asc (salary ASC);
ALTER TABLE salaries ADD INDEX ix_salary_desc (salary DESC);

SELECT *
  FROM salaries
 ORDER BY COS(salary);
 
SELECT emp_no, (SELECT dept_name FROM departments WHERE dept_name='Sales1') as sales
  FROM dept_emp LIMIT 10;
  
SELECT COUNT(CONCAT(e1.first_name,
				   (SELECT e2.first_name FROM employees e2 WHERE e2.emp_no=e1.emp_no))
                   ) FROM employees e1;
SELECT COUNT(CONCAT(e1.first_name, e2.first_name))
  FROM employees e1, employees e2
 WHERE e1.emp_no=e2.emp_no;
 
 
SELECT e.emp_no, e.first_name,
	   s2.salary, s2.from_date, s2.to_date
  FROM employees e
    INNER JOIN LATERAL (
      SELECT * FROM salaries s
      WHERE s.emp_no = e.emp_no
      ORDER BY s.from_date DESC
      LIMIT 1) s2 ON s2.emp_no=e.emp_no
  WHERE e.emp_no=499999;
  
EXPLAIN SELECT * FROM (SELECT * FROM employees) y;

EXPLAIN 
SELECT * 
  FROM dept_emp de WHERE (emp_no, from_date) = (
	   SELECT emp_no, from_date
         FROM salaries
         WHERE emp_no=100001 limit 1);
         
SELECT *
  FROM employees e
 WHERE e.emp_no IN
	  (SELECT de.emp_no FROM dept_emp de WHERE de.from_date='1995-01-01');
      
WITH cte1 AS (SELECT * FROM departments)
SELECT * FROM cte1;

SELECT * FROM (SELECT * FROM departments) cte1;

WITH RECURSIVE cte (no) AS (
  SELECT 1
  UNION ALL
  SELECT (no + 1) FROM cte WHERE no <5
  )
  SELECT * FROM cte;
  
WITH RECURSIVE cte (no) AS (
  SELECT 1 as no
  UNION ALL
  SELECT (no + 1) as no FROM cte WHERE no < 1000
)
SELECT * FROM cte;

use employees;

SELECT emp_no, from_date, salary,
		AVG(salary) OVER() AS avg_salary
  FROM salaries
  WHERE emp_no=10001
  LIMIT 5;
  
SELECT emp_no, from_date, salary,
		AVG(salary) OVER() AS avg_salary
  FROM (SELECT * FROM salaries WHERE emp_no=10001 LIMIT 5) s2;
  
SELECT e.* ,
		RANK() OVER(ORDER BY e.hire_date) AS hire_date_rank
  FROM employees e;
  
SELECT de.dept_no, e.emp_no, e.first_name, e.hire_date,
		RANK() OVER(PARTITION BY de.dept_no ORDER BY e.hire_date) AS hire_date_rank
  FROM employees e
	INNER JOIN dept_emp de ON de.emp_no=e.emp_no
  ORDER BY de.dept_no, e.hire_date;
  
SELECT emp_no, from_date, salary,
		AVG(salary) OVER() AS avg_salary
  FROM salaries
 WHERE emp_no=10001;
 
SELECT *
  FROM employees e
	INNER JOIN dept_emp de ON de.emp_no=e.emp_no
    INNER JOIN departments d ON d.dept_no=de.dept_no
  FOR UPDATE;

SELECT *
  FROM employees e
	INNER JOIN dept_emp de ON de.emp_no=e.emp_no
    INNER JOIN departments d ON d.dept_no=de.dept_no
  WHERE e.emp_no=10001
  FOR UPDATE OF e;
  
BEGIN;
SELECT * FROM employees WHERE emp_no=10001 FOR UPDATE;

SELECT *
  FROM employees
 WHERE emp_no=10001
 FOR UPDATE NOWAIT;

SELECT * FROM employees WHERE emp_no=10001 FOR UPDATE NOWAIT;

INSERT IGNORE INTO salaries(emp_no, salary, from_date, to_date) VALUES
	(10001, 60117, '1986-06-26', '1987-06-26'),
    (10001, 62102, '1987-06-26', '1988-06-25'),
    (10001, 66074, '1988-06-25', '1989-06-25'),
    (10001, 66596, '1989-06-25', '1990-06-25'),
    (10001, 66961, '1990-06-25', '1991-06-25');

INSERT IGNORE INTO salaries
	SELECT emp_no, (salary+100), '2020-01-01', '2022-01-01'
      FROM salaries WHERE to_date>='2020-01-01';
      
CREATE TABLE daily_statistic(
		target_date DATE NOT NULL,
        start_name VARCHAR(10) NOT NULL,
        start_value BIGINT NOT NULL DEFAULT 0,
        PRIMARY KEY(target_date, start_name)
        );

INSERT INTO daily_statistic (target_date, start_name, start_value)
		VALUE (DATE(NOW()), 'VISIT', 1)
        ON DUPLICATE KEY UPDATE start_value=start_value+1;
        
INSERT INTO daily_statistic
	SELECT DATE(visited_at), 'VISIT', COUNT(*)
      FROM access_log
      GROUP BY DATE(visited_at)
      ON DUPLICATE KEY UPDATE start_value=start_value + COUNT(*);

INSERT INTO daily_statistic
	SELECT DATE(visited_at), 'VISIT', COUNT(*)
    FROM access_log
    GROUP BY DATE(visited_at)
    ON DUPLICATE KEY UPDATE start_value=start_value + VALUES(start_value);
    
INSERT INTO daily_statistic (target_date, start_name, start_value)
	VALUES ('2020-09-01', 'VISIT', 1),
		   ('2020-09-02', 'VISIT', 1)
		AS new
	ON DUPLICATE KEY
		UPDATE daily_statistic.start_value=daily_statistic.start_value+new.start_value;
	
INSERT INTO daily_statistic 
		SET target_date='2020-09-01', start_name='VISIT', start_value=1 AS new
	ON DUPLICATE KEY
		UPDATE daily_statistic.start_value=daily_statistic.start_value+new.start_value;
        
INSERT INTO daily_statistic
		SET target_date='2020-09-01', start_name='VISIT', start_value=1 AS new(fd1, fd2, fd3)
	ON DUPLICATE KEY
		UPDATE daily_statistic.start_value=daily_statistic.start_value+new.fd3;