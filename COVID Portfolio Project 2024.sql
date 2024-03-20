SELECT *
FROM [PortfolioProject].[dbo].[CovidDeaths]
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM [PortfolioProject].[dbo].[CovidVaccinations]
--ORDER BY 3,4

-- SELECT Data that we are going to be using

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM [PortfolioProject].[dbo].[CovidDeaths]
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths

SELECT Location, Date, total_cases, CAST(total_deaths AS float), CAST(total_deaths AS float)/CAST(total_cases as float)*100 as DeathPercentage
FROM [PortfolioProject].[dbo].[CovidDeaths]
WHERE location = 'United States' AND continent is not null
ORDER BY 1,2

-- Looking at total cases vs population

SELECT Location, Date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
FROM [PortfolioProject].[dbo].[CovidDeaths]
WHERE location = 'United States'
ORDER BY 1,2

-- What countries have highest infection rates

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases)/population)*100 as PercentPopulationInfected
FROM [PortfolioProject].[dbo].[CovidDeaths]
GROUP BY Location,population
ORDER BY PercentPopulationInfected DESC


-- What countries have highest death rates

SELECT Location, MAX(total_deaths) as TotalDeathCount
FROM [PortfolioProject].[dbo].[CovidDeaths]
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC


-- Break things down by continent


SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM [PortfolioProject].[dbo].[CovidDeaths]
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT Date, SUM(new_cases) AS TotalNewCases, SUM(new_deaths) AS TotalNewDeaths, SUM(CAST(new_deaths AS float))/SUM(NULLIF(new_cases,0))*100 AS DeathPercentage
FROM [PortfolioProject].[dbo].[CovidDeaths]
WHERE continent is not null
GROUP BY date
ORDER BY date

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [PortfolioProject].[dbo].[CovidDeaths] dea
JOIN [PortfolioProject].[dbo].[CovidVaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3


-- Looking at Total Population vs Vaccinations - using CTEs to show how to use RollingPeopleVaccinated (a newly created output) in a calculation.

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [PortfolioProject].[dbo].[CovidDeaths] dea
JOIN [PortfolioProject].[dbo].[CovidVaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- Looking at % Population Vaccinated - using TEMP TABLE to show how to use RollingPeopleVaccinated (a newly created output) in a calculation.

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [PortfolioProject].[dbo].[CovidDeaths] dea
JOIN [PortfolioProject].[dbo].[CovidVaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Create a view to store data for later visualisations

USE [PortfolioProject]
GO
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [PortfolioProject].[dbo].[CovidDeaths] dea
JOIN [PortfolioProject].[dbo].[CovidVaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3