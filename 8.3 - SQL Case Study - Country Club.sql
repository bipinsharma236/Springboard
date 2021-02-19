/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT DISTINCT 
FROM Facilities 
WHERE Facilities.membercost > 0.0;


/* Q2: How many facilities do not charge a fee to members? */
SELECT COUNT(DISTINCT name)
FROM Facilities
WHERE membercost = 0.0;


/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost > 0.0 AND membercost < (0.2*monthlymaintenance);


/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */
SELECT * 
FROM Facilities
WHERE facid in (1,5);


/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */
SELECT name, monthlymaintenance,
CASE WHEN monthlymaintenance > 100 THEN 'expensive'
ELSE 'cheap' END AS cost
FROM Facilities


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */
SELECT firstname, surname, MAX(joindate)
FROM Members



/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT subquery.name, subquery.membername
FROM (SELECT DISTINCT b.memid, b.facid, f.name, CONCAT(m.firstname, ' ', m.surname) AS membername
FROM Bookings as b
LEFT JOIN Facilities as f
ON b.facid = f.facid AND f.facid in (0,1)
LEFT JOIN Members as m
ON m.memid = b.memid) AS subquery
WHERE subquery.name IS NOT NULL
ORDER BY membername



/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
SELECT f.name, CONCAT(m.firstname,' ',m.surname) AS membername,
CASE WHEN b.memid = 0 THEN slots*f.guestcost
ELSE slots*f.membercost
END AS cost
FROM Bookings as b
JOIN Members as m
ON b.memid = m.memid
JOIN Facilities as f
ON b.facid = f.facid
HAVING cost>30.0


/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT name, membername, cost
FROM (SELECT f.name as name, CONCAT(m.firstname,' ',m.surname) AS membername,
      CASE WHEN b.memid = 0 THEN slots*f.guestcost
      ELSE slots*f.membercost
      END AS cost
      FROM Bookings as b
      JOIN Members as m
      ON b.memid = m.memid
      JOIN Facilities as f
      ON b.facid = f.facid) as subquery
WHERE cost>30.0



/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
SELECT name, cost, sum(cost) AS revenue
FROM (SELECT f.name as name,
      CASE WHEN b.memid = 0 THEN slots*f.guestcost
      ELSE slots*f.membercost
      END AS cost
      FROM Bookings as b
      JOIN Members as m
      ON b.memid = m.memid
      JOIN Facilities as f
      ON b.facid = f.facid) AS subquery
GROUP BY name
HAVING revenue < 1000


/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
SELECT CONCAT(m1.surname, ', ', m1.firstname) AS member_name, CONCAT(m2.surname, ', ', m2.firstname) AS recommended_by
FROM Members AS m
INNER JOIN Members AS m1 on m1.memid = m.memid
INNER JOIN Members m2 on m2.memid = m.recommendedby
ORDER BY member_name




/* Q12: Find the facilities with their usage by member, but not guests */
SELECT DISTINCT f.name AS facility
FROM Facilities AS f
LEFT JOIN Bookings AS b
ON b.facid = f.facid
WHERE b.memid <> 0




/* Q13: Find the facilities usage by month, but not guests */
SELECT DISTINCT f.name AS facility, MONTH(b.starttime) as month
FROM Facilities AS f
LEFT JOIN Bookings AS b
ON b.facid = f.facid
WHERE b.memid <> 0


