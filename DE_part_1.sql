-- Looking at the Total Cases vs Total Deaths

SELECT Location, date, total_cases,total_deaths, 
	(total_deaths/total_cases)*100 as Percent_Death
FROM PortfolioProject..CovidDeaths
WHERE location like '%india%'
ORDER BY Percent_Death DESC;


-- Looking at the Total Cases vs Population
-- What pecentage of population got covid

SELECT Location, date,population, total_cases,(total_cases/population)*100 as Percent_Cases
FROM PortfolioProject..CovidDeaths
WHERE location like '%india%'
ORDER BY 1,2;


-- Looking at countries with highest infection rate compared to population 

SELECT Location,population, MAX(total_cases) as Highest_Infc_Count,
	MAX((total_cases/population))*100 as Percent_Cases
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY Percent_Cases Desc;

-- Looking at countries with highest death count

SELECT Location,MAX(CAST(total_deaths as int)) as Highest_Death_Count
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location 
ORDER BY Highest_Death_Count Desc;


-- Looking at the countries with the highest death count compared to population

SELECT Location,population, MAX(CAST(total_deaths as int)) as Highest_Death_Count,
	MAX((total_deaths/population))*100 as Percent_Deaths
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY Percent_Deaths Desc;

-- Breaking things by continent 

SELECT location, MAX(CAST(total_deaths as int)) as Highest_Death_Count
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY Highest_Death_Count DESC;

-- Looking at the continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths as int)) as Highest_Death_Count
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
GROUP BY continent
ORDER BY Highest_Death_Count DESC;


-- Global numbers

SELECT date, SUM(new_cases) total_cases, SUM(CAST(new_deaths as int)) total_deaths, 
	SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as percent_new_death
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;


SELECT  SUM(new_cases) total_cases, SUM(CAST(new_deaths as int)) total_deaths, 
	SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as percent_new_death
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2;

--JOINS

-- Looking at total polulation vs total vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..Covid_Vaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;

-- Roll up SUM of vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations as int)) 
		OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as Rolling_vaccination
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..Covid_Vaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;


-- using CTE 

WITH Population_vs_Vaccination (continent, location, date, population, new_vaccinations,Rolling_vaccination)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations as int)) 
		OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as Rolling_vaccination
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..Covid_Vaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)

SELECT *, (Rolling_vaccination/population)*100
FROM Population_vs_Vaccination


