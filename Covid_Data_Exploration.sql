/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/
/*Displaying All the data in table COVID Deaths*/

SELECT *
FROM dbo.CovidDeaths


/*Data type for total_deaths and total_cases is varchar so converting 
to Decimal for numerical calculations.*/

Alter table CovidDeaths Alter Column total_deaths DECIMAL;
Alter table CovidDeaths Alter Column total_cases DECIMAL;

-- Looking at Total cases vs Total deaths (And percentage of death by cases)

SELECT Location, date, total_cases, total_deaths, Cast((total_deaths*100/total_cases) as decimal(18,3)) as Percent_Deaths
FROM dbo.CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2

-- Looking at total cases vs total population
-- Shows what percentage of total population got COVID by Country(for eg, US)

SELECT location, date, population, total_cases, CAST((total_cases*100/population) as decimal(18,3)) as Percent_Infection
FROM dbo.CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2

-- Looking at Maximum Infection Rate by Population in Decreasing Order
SELECT location, population, MAX(total_cases) as HighestCases, MAX(CAST((total_cases*100/population) as decimal(18,3))) as Max_Percent_Infection
FROM dbo.CovidDeaths
WHERE continent is NOT NULL
GROUP By [location],population
ORDER BY Max_Percent_Infection DESC


-- Looking at Percent Deaths by Population of Countries Decreasing Order
SELECT location, population, MAX(total_deaths) as Total_Death, MAX(CAST((total_deaths*100/population) as decimal(18,3))) as Percent_Deaths_by_Population
FROM dbo.CovidDeaths
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY Percent_Deaths_by_Population DESC


-- Looking ar Percent Deaths by Continent 
SELECT continent, MAX(total_deaths) as Total_Deaths, MAX(CAST((total_deaths*100/population) as decimal(18,3))) as Percent_Deaths  
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Deaths desc


-- GLOBAL NUMBERS

SELECT * from dbo.CovidDeaths

-- New_cases and New_deaths was converted to numeric from varchar
Alter table CovidDeaths Alter Column new_cases DECIMAL;
Alter table CovidDeaths Alter Column new_deaths DECIMAL;

-- Looking at daily total new cases vs total_death percentage 
SELECT date, SUM(new_cases) as Total_Cases, SUM(new_deaths) as Total_Deaths, SUM(new_deaths)*100/SUM(new_cases) as DeathPercentage
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY [date]

-- Looking at worlds total cases with total deaths and its percent.

SELECT SUM(new_cases) as Total_Cases, SUM(new_deaths) as Total_Deaths, SUM(new_deaths)*100/SUM(new_cases) as DeathPercent_World
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


SELECT * FROM dbo.CovidVaccination


-- Looking at Total population vs Vaccinated population using Rolling Window

SELECT DEA.[date], DEA.continent, DEA.[location], DEA.population, VAC.new_vaccinations, 
SUM(CONVERT( INT,VAC.new_vaccinations)) OVER (PARTITION BY DEA.[location] ORDER BY DEA.LOCATION, DEA.DATE) AS RollingPeople_Vaccinated
FROM dbo.CovidDeaths DEA
JOIN dbo.CovidVaccination VAC
ON DEA.[date] = VAC.[date]
AND DEA.[location] = VAC.[location] 
WHERE DEA.continent IS NOT NULL
--AND DEA.[location] like '%states%'
ORDER BY 3,1


-- Creating CTE for the Rooling window function for Percemt Population Vaccinated. 

WITH PopuvsVacci (date, continent, location, Population, new_vaccinations, RollingPeople_Vaccinated)
AS
(
SELECT DEA.[date], DEA.continent, DEA.[location], DEA.population, VAC.new_vaccinations,
    SUM(cast(VAC.new_vaccinations as int)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.DATE) AS RollingPeople_Vaccinated
FROM dbo.CovidDeaths DEA
JOIN dbo.CovidVaccination VAC
ON DEA.[date] = VAC.[date]
AND DEA.[location] = VAC.[location]
WHERE DEA.continent IS NOT NULL
)

SELECT * , (RollingPeople_Vaccinated/Population)*100 AS Percent_Population_Vaccinated
FROM PopuvsVacci
ORDER BY 2,3



-- Creating TEMP Table for Calculating Max Fully Percent population Vaccinated (2 doses) by Country. 

DROP Table IF exists #MaxPopulationVaccinated
CREATE TABLE #MaxPopulationVaccinated
(
    Date DATETIME,
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Population NUMERIC,
    New_Vaccination NUMERIC,
    RollingPeople_Vaccinated NUMERIC,
)

INSERT INTO #MaxPopulationVaccinated
SELECT DEA.[date], DEA.continent, DEA.[location], DEA.population, VAC.new_vaccinations,
    SUM(cast(VAC.new_vaccinations as int)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.DATE) AS RollingPeople_Vaccinated
FROM dbo.CovidDeaths DEA
JOIN dbo.CovidVaccination VAC
ON DEA.[date] = VAC.[date]
AND DEA.[location] = VAC.[location]
WHERE DEA.continent IS NOT NULL

SELECT Continent, [Location], Max(Population) as Polulation, MAX(RollingPeople_Vaccinated)AS Total_Vaccianted,  
(CAST(MAX(RollingPeople_Vaccinated)/2 as int)/ Max(Population))*100 AS Percent_Population_Vaccinated
FROM #MaxPopulationVaccinated
WHERE RollingPeople_Vaccinated IS NOT NULL
GROUP BY  [Location], Continent
ORDER BY 1,2

