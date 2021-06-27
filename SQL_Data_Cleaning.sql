/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

/*Displaying All the data in table COVID Deaths*/

SELECT *
from dbo.CovidDeaths


/*Data type for total_deaths and total_cases is varchar so converting 
to Decimal for numerical calculations.*/

Alter table CovidDeaths Alter Column total_deaths DECIMAL;
Alter table CovidDeaths Alter Column total_cases DECIMAL;

-- Looking at Total cases vs Total deaths (And percentage of death by cases)

SELECT Location, date, total_cases, total_deaths, Cast((total_deaths*100/total_cases) as decimal(18,3)) as Percent_Deaths
from dbo.CovidDeaths
WHERE location like '%states%'
order by 1,2

-- Looking at total cases vs total population
-- Shows what percentage of total population got COVID by Country(for eg, US)
SELECT location, date, population, total_cases, CAST((total_cases*100/population) as decimal(18,3)) as Percent_cases
FROM dbo.CovidDeaths
WHERE location like '%states%'
order by 2





