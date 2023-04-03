
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4


--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in your country
SELECT 
    location, 
    date, 
    total_cases, 
    total_deaths, 
    CONVERT(DECIMAL(18, 2), (CONVERT(DECIMAL(18, 2), total_deaths) / CONVERT(DECIMAL(18, 2), total_cases)))*100 as DeathsPercentage
from PortfolioProject..CovidDeaths
WHERE Location like '%states%'
order by 1,2

--Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT 
    location, 
    date, 
	population,
    total_cases, 
    CONVERT(DECIMAL(18, 2), (CONVERT(DECIMAL(18, 2), total_cases) / CONVERT(DECIMAL(18, 2), population)))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
WHERE Location like '%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to population

SELECT 
    location, 
	population,
    MAX(total_cases) as HighestInfectionCount, 
    CONVERT(DECIMAL(18, 2), (CONVERT(DECIMAL(18, 2), MAX(total_cases)) / CONVERT(DECIMAL(18, 2), population)))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
WHERE continent is not null
GROUP BY location, population
order by PercentPopulationInfected desc

--Showing Countries with highest death count per population

SELECT 
    location, 
    MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
WHERE continent is not null
GROUP BY location
order by TotalDeathCount desc

--Broken down by continent
--Showing the continents with the highest death count per population

SELECT 
    continent, 
    MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
WHERE continent is not null
GROUP BY continent
order by TotalDeathCount desc



--Looking at Total Polutation vs Vaccinations

SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations
, SUM(CONVERT(bigint,b.new_vaccinations)) OVER (Partition by a.location ORDER BY a.location,a.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths a
JOIN PortfolioProject..CovidVaccinations b
	ON a.location=b.location
	AND a.date=b.date
WHERE a.continent is not null
ORDER By 2,3

--USE CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations
, SUM(CONVERT(bigint,b.new_vaccinations)) OVER (Partition by a.location ORDER BY a.location,a.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths a
JOIN PortfolioProject..CovidVaccinations b
	ON a.location=b.location
	AND a.date=b.date
WHERE a.continent is not null
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

--Temp Table
DROP TABLE IF exists #PercentPopVaccinated
CREATE TABLE #PercentPopVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopVaccinated
SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations
, SUM(CONVERT(bigint,b.new_vaccinations)) OVER (Partition by a.location ORDER BY a.location,a.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths a
JOIN PortfolioProject..CovidVaccinations b
	ON a.location=b.location
	AND a.date=b.date
WHERE a.continent is not null
ORDER By 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopVaccinated

--Creating View to store data for later visualizations 
CREATE VIEW PercentPopVaccinated as
SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations
, SUM(CONVERT(bigint,b.new_vaccinations)) OVER (Partition by a.location ORDER BY a.location,a.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths a
JOIN PortfolioProject..CovidVaccinations b
	ON a.location=b.location
	AND a.date=b.date
WHERE a.continent is not null

SELECT *
FROM PercentPopVaccinated