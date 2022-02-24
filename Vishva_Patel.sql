--query 1
--Identify the users who try to logon before 2017 but never try to logon during 2017. Eliminate duplicate lines from your output. 

select DISTINCT Security_Logins.Login AS "User Login",
				Security_Logins.Full_Name AS "User Name",
				Security_Logins.Phone_Number AS "User Phone"  
FROM dbo.Security_Logins
INNER JOIN dbo.Security_Logins_Log	
ON dbo.Security_Logins.Id = dbo.Security_Logins_Log.Login
WHERE DATEPART(YEAR, Logon_Date) < 2017 
AND Security_Logins_Log.Login 
not in (select Login from Security_Logins_Log
where DATEPART(year, Logon_Date) = 2017);


--query 2
--Identify the companies where applicants applied for the job 10 or more times. Eliminate duplicate lines from your output.

select Distinct Company_Name
--COUNT(Applicant_Job_Applications.Id) as total
from Applicant_Job_Applications
inner join Company_Jobs
on Company_Jobs.Id = Applicant_Job_Applications.Job
inner join Company_Profiles on Company_Jobs.Company = Company_Profiles.Id
inner join Company_Descriptions on Company_Descriptions.Company = Company_Profiles.Id 
and Company_Descriptions.LanguageID = 'EN'
group by Company_Name
having COUNT(Applicant_Job_Applications.Id) >= 10
Order by Company_Name;

--query 3
--Identify the Applicants with highest current salary for each Currency.

select Applicant_Profiles.Currency,max( Applicant_Profiles.Current_Salary)
from Applicant_Profiles
group by Currency;

--query 4
--For each company, determine the number of jobs posted. If a company doesn't have posted jobs, show 0 for that company. 

select Distinct Company_Name, COUNT(Company_Jobs.Id) as total
from Company_Profiles
left join Company_Jobs on Company_Jobs.Company = Company_Profiles.Id
inner join Company_Descriptions on Company_Descriptions.Company = Company_Profiles.Id 
and Company_Descriptions.LanguageID = 'EN'
group by Company_Name
Order by total;

--query 5
--Determine the total number of companies that have posted jobs and the total number of companies that has never posted jobs in one data set with 2 rows like the one below:


select 'Clients with Posted Job:', count (*) as total
from (select Distinct Company_Name, COUNT(Company_Jobs.Id) as total
from Company_Profiles
left join Company_Jobs on Company_Jobs.Company = Company_Profiles.Id
inner join Company_Descriptions on Company_Descriptions.Company = Company_Profiles.Id 
group by Company_Name
having COUNT(Company_Jobs.Id) > 0) as q1
Union all
select 'Clients without Posted Jobs:', count (*) as total
from (select Distinct Company_Name, COUNT(Company_Jobs.Id) as total
from Company_Profiles
left join Company_Jobs on Company_Jobs.Company = Company_Profiles.Id
inner join Company_Descriptions on Company_Descriptions.Company = Company_Profiles.Id 
group by Company_Name
having COUNT(Company_Jobs.Id) = 0) as q2;



















 