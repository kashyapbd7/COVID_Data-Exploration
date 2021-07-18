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


