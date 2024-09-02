-- Number of rows into our dataset
Select count(*) from Project_Population_census..Sheet1;
-- 640 rows
Select count(*) from Project_Population_census..Sheet1;
-- 640 rows


--dataset for Jharkhand and Bihar
Select * from Project_Population_census..Sheet1 where State IN ('Jharkhand','Bihar');

--Population for India
Select sum(Population) AS Total_population from Project_Population_census..Sheet2;

-- Average Growth rate in India
Select avg(Growth)*100 as Average_growth_rate from Project_Population_census..Sheet1;

-- Average Growth rate by State
Select State, avg(Growth)*100 as Average_growth 
from Project_Population_census..Sheet1 
group by State
Order by Average_growth desc;

-- Average Sex-ratio by State
Select State, round(avg(Sex_Ratio),0) as Average_sex_ratio 
from Project_Population_census..Sheet1 
group by State
Order by Average_sex_ratio  asc;

-- Average Literacy rate by State 
Select State, round(avg(Literacy),0) as Average_Literacy_rate 
from Project_Population_census..Sheet1 
group by State having round(avg(Literacy),0) > 90
Order by Average_Literacy_rate desc;

-- Top and bottom 3 states by Growth Rate


--Selecting states starting with a or b
Select distinct state from Project_Population_census..Sheet1 
where LOWER(State) LIKE 'a%' OR LOWER(State) LIKE 'b%';

--Selecting states starting with a and ending with m
Select distinct state from Project_Population_census..Sheet1 
where LOWER(State) LIKE 'a%' and LOWER(State) LIKE '%m';

select * from Project_Population_census..Sheet1;
select * from Project_Population_census..Sheet2;

--Joining both tables
--Total males and females
Select d.State, SUM(d.Males) AS Total_males, SUM(d.Females) AS Total_females FROM
(Select c.District, c.State, round(c.Population/(c.Sex_Ratio + 1),0) AS Males,
round((c.Population*c.Sex_Ratio)/(c.Sex_Ratio+1),0) AS Females 
FROM
(Select a.District, a.State, a.Sex_Ratio/1000 AS Sex_Ratio, b.Population 
from Project_Population_census..Sheet1 AS a
INNER JOIN Project_Population_census..Sheet2 AS b
ON a.District = b.District) c) d
GROUP BY d.State;

--Total literacy rates by States

Select d.State, SUM(Literate_people) AS total_literacy, SUM(Illiterate_people) AS total_illiteracy from 
(Select c.District, c.State, round(c.literacy_ratio*c.population,0)  AS Literate_people, 
round((1-c.literacy_ratio)*c.population,0) AS Illiterate_people FROM
(Select a.District, a.State, a.Literacy/100 AS literacy_ratio, b.Population 
from Project_Population_census..Sheet1 AS a
INNER JOIN Project_Population_census..Sheet2 AS b
ON a.District = b.District) c) d
group by d.State;

--Population in previous census
Select sum(e.Previous_censusdata) AS Previous_censusdata, SUM(e.Current_censusdata) AS Current_censusdata FROM
(Select d.State, SUM(d.Previous_censusdata) AS Previous_censusdata, SUM(d.Current_censusdata) AS Current_censusdata FROM
(Select c.District, c.State, round(c.Population/(1+c.Growth),0) AS Previous_censusdata, c.Population AS Current_censusdata from
(Select a.District, a.State, a.Growth AS Growth, b.Population 
from Project_Population_census..Sheet1 AS a
INNER JOIN Project_Population_census..Sheet2 AS b
ON a.District = b.District) c) d
Group by d.State) e;

-- Population vs area 
select g.Total_area/g.Previous_censusdata, g.Total_area/g.Current_censusdata FROM
(select q.*,r.Total_area from
(select '1' as keyy,n.* from
(Select sum(e.Previous_censusdata) AS Previous_censusdata, SUM(e.Current_censusdata) AS Current_censusdata FROM
(Select d.State, SUM(d.Previous_censusdata) AS Previous_censusdata, SUM(d.Current_censusdata) AS Current_censusdata FROM
(Select c.District, c.State, round(c.Population/(1+c.Growth),0) AS Previous_censusdata, c.Population AS Current_censusdata from
(Select a.District, a.State, a.Growth AS Growth, b.Population 
from Project_Population_census..Sheet1 AS a
INNER JOIN Project_Population_census..Sheet2 AS b
ON a.District = b.District) c) d
Group by d.State) e) n) q inner join (
select '1' as keyy,z.* from
(Select sum(area_km2) as Total_area from Project_Population_census..Sheet2) z) r on q.keyy=r.keyy) g

--Output top 3 districts from each state with highest literacy ratio
Select a.* from
(select district, state, literacy, rank() over(partition by state order by literacy desc) rnk 
from Project_Population_census..Sheet1) a
where a.rnk in (1,2,3) order by state;

