/*
Selecting all data from the CovidDeaths table where the Continent column isn't Null
*/

CREATE VIEW Data_CovidDeaths_Table AS
SELECT * 
FROM [SQLDataExplorationProject-Covid19]..CovidDeaths
WHERE continent IS NOT NULL
--ORDER BY 3, 4



/*
Selecting the data from CovidDeaths table that'll be used in this project:
*/

CREATE VIEW Project_Specific_CovidDeaths_Data AS
SELECT 
	[location], 
	[date], 
	[total_cases], 
	[new_cases], 
	[total_deaths], 
	[population]
FROM [SQLDataExplorationProject-Covid19]..CovidDeaths
WHERE [continent] IS NOT NULL
--ORDER BY 3, 4




--Total Cases vs. Total Deaths + Likelihood of Dying From Covid-19 Based on Location
/*
This view shows the likelihood of dying from Covid19 if you lived in the U.S.
For example, as of today (1/22/23), you would have around a 1.08% of dying from Covid19 if you contracted it and lived in the United States (excluding the U.S. Virgin Islands). 
*/

CREATE VIEW TotalCases_v_TotalDeaths_And_DeathLikelihood AS
SELECT 
	[location], 
	[date], 
	[total_cases], 
	[total_deaths], 
	(total_deaths/total_cases)*100 AS Likelihood_of_Death_Percentage
FROM [SQLDataExplorationProject-Covid19]..CovidDeaths
WHERE [continent] IS NOT NULL
--ORDER BY [date] DESC




--Total Cases vs. Population
/*
This view shows what percentage of the population contracted Covid19.
For example, as of today (1/22/23), around 30% of the U.S. population has contracted Covid-19.
*/
CREATE VIEW TotalCases_v_Population_And_PercOfPopInfected AS
SELECT 
	[location], 
	[date], 
	[population], 
	[total_cases], 
	(total_cases/population)*100 AS Percentage_of_Population_Infected
FROM [SQLDataExplorationProject-Covid19]..CovidDeaths
WHERE [continent] IS NOT NULL
--ORDER BY [date] DESC




--Current Highest-Recorded Count of Total Cases vs. The Percentage of Population That Has Been Infected
/*
This query shows the population count of a country, its highest-recorded total cases (i.e. the amount of cases it has accumulated up until today's date - 1/24/23),
and the percentage of how much of its population has been infected (up until today) with Covid-19.

For example, Austria has recorded around 5,755,617 cases of Covid-19 from the start of the spread up until today. 
Likewise, around 64% of Austria's population has contracted Covid-19.
*/
CREATE VIEW TotalCasesCount_v_PercOfPopInfected AS
SELECT 
	[location],
	[population], 
	MAX(total_cases) AS Highest_Infection_Count_Recorded, 
	MAX((total_cases/population)*100) AS Percentage_of_Population_Infected
FROM [SQLDataExplorationProject-Covid19]..CovidDeaths
WHERE [continent] IS NOT NULL
GROUP BY 
	[location],
	[population]
--ORDER BY Percentage_of_Population_Infected DESC




--Countries With Their Current Total Death Count
/*
This view shows the names of locations and the total amount of Covid-19-related deaths each of them currently has.

For example, the United States currently has the highest death toll of around 1,104,118 deaths.
*/
CREATE VIEW Current_Total_Death_Count_ByCountry AS
SELECT 
	[location], 
	MAX(cast(total_deaths as int)) AS Current_Total_Death_Toll
FROM [SQLDataExplorationProject-Covid19]..CovidDeaths
WHERE [continent] IS NOT NULL
GROUP BY [location]
--ORDER BY Current_Total_Death_Toll DESC




--Breaking Things Down By Continents:



--Continents With Their Current Total Death Count
/*
This view shows the same content as the previous query, except with regards to continents.

For instance, North America has the highest recored Covid-19 death toll with around 1,104,118

*Please note that some of the data that I'm displaying is a bit skewed; there are some feilds in the CovidDeaths table wherein the [continent] column is empty.
E.g. the [location] of Oceania has NULL in its [continent] column. 
*/
CREATE VIEW Current_Total_Death_Count_ByContinent AS
SELECT 
	[continent], 
	MAX(cast(total_deaths as int)) AS Current_Total_Death_Toll
FROM [SQLDataExplorationProject-Covid19]..CovidDeaths
WHERE [continent] IS NOT NULL
GROUP BY [continent]
--ORDER BY Current_Total_Death_Toll DESC




--Global Numbers:




--Total Cases Globally vs. Total Deaths Globally + Global Death Toll Percentage
/*
This view shows the date, how many new cases and new deaths occured on that date (globally), and the likelihood of dying from Covid-19 (if contracted) on that particular date.

For example, as of today (1/22/23), there were around 113,854 new Covid-19 cases and around 596 new deaths around the world.
Regardless of whether you contracted Covid-19 today or still currently have the symptoms of Covid-19, you would have a likelihood of 0.5% chance of dying from it today (regardless of where you lived).
*/

CREATE VIEW DailyTotalCasesGlobally_v_DailyTotalDeathsGlobally_and_DailyGlobalDeathTollPercentage AS
SELECT 
	[date], 
	SUM(new_cases) AS Total_New_Cases_Globally, 
	SUM(cast(new_deaths as int)) AS Total_New_Deaths_Globally, 
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS Global_Death_Likelihood_Percentage
FROM [SQLDataExplorationProject-Covid19]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
--ORDER BY date DESC




--Creating a view to look at the total number of new cases, new deaths, and the global death percentage across the globe.

CREATE VIEW TotalNewCasesGlobally_v_TotalNewDeathsGlobally_and_GlobalDeathPercentage AS
SELECT 
	SUM(new_cases) AS Total_New_Cases_Globally, 
	SUM(cast(new_deaths as int)) AS Total_New_Deaths_Globally, 
	SUM(cast(new_deaths as int))/SUM(new_cases) AS Global_Death_Likelihood_Percentage
FROM [SQLDataExplorationProject-Covid19]..CovidDeaths
WHERE continent IS NOT NULL




--Looking at total population vs. vaccinations 
/*
The query inside of this CTE/With-Table shows the continent, the specific location in that continent, the date, it's population, the number of new vaccinations (in that location) per day, and then a
rolling count of the amount of new people that got vaccinated.

For example, the first recorded day of new vaccinations in the United States was on 12/14/20, and around 4804 people got vaccinations. The next day, 47,706 new people got vaccinated.
Combining the numbers from the previous day and the day after gives around 52,510 people vaccinated in total (as of 12/15/20).
*/
CREATE VIEW Percent_Population_Vaccinated AS
WITH TotalPopulation_VS_PopulationVaccinated (continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated) AS
(
SELECT 
	deaths.[continent],
	deaths.[location], 
	deaths.[date], 
	deaths.[population], 
	vaccinations.[new_vaccinations], 
	SUM(cast(vaccinations.[new_vaccinations] as bigint)) OVER (PARTITION BY deaths.[location] ORDER BY deaths.[location], deaths.[date]) AS Rolling_People_Vaccinated
FROM [SQLDataExplorationProject-Covid19]..CovidDeaths deaths
JOIN [SQLDataExplorationProject-Covid19]..CovidVaccinations vaccinations
	ON deaths.[location] = vaccinations.[location] 
	AND deaths.[date] = vaccinations.[date]
WHERE deaths.[continent] IS NOT NULL 
)


/*
The CTE/With-Table above was created for the purpose of using the Rolling_People_Vaccinated value and dividing it by the population to get the percentage of the population
who had gotten vaccinated on any particular day.

The query down below shows exactly this. It is executed along with the creation of the CTE/With-Table above.
*/
Select *, (Rolling_People_Vaccinated/Population)*100 AS Percentage_Of_Population_Vaccinated
FROM TotalPopulation_VS_PopulationVaccinated








