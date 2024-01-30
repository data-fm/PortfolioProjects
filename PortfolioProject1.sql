Select *
FROM ProjectPortfolio..CovidDeaths
WHERE continent is not null
ORDER BY 3, 4

--Select *
--FROM ProjectPortfolio..CovidVaccinations
--ORDER BY 3, 4

--Select Data that we are going to be using
Select Location, date, total_cases, New_cases, total_deaths, population
FROM ProjectPortfolio..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2


-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM ProjectPortfolio..CovidDeaths
WHERE location like '%canada%' AND continent is not null
ORDER BY 1, 2

-- Looking at the Total Cases vs Population
-- Shows percentage of population that got covid
Select Location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM ProjectPortfolio..CovidDeaths
WHERE location like '%states%' AND continent is not null
ORDER BY 1, 2

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM ProjectPortfolio..CovidDeaths
WHERE continent is not null
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

-- Looking at Countries with Highest Death Count per Population
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM ProjectPortfolio..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM ProjectPortfolio..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

--Death Percentage by date
SELECT  date, sum(new_Cases) AS total_cases, sum(cast(new_deaths as int)) AS total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 AS DeathPercentage
FROM ProjectPortfolio..CovidDeaths
WHERE continent is not null
group by date
order by 1, 2

-- Death Percentage total Worldwide
SELECT  sum(new_Cases) AS total_cases, sum(cast(new_deaths as int)) AS total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 AS DeathPercentage
FROM ProjectPortfolio..CovidDeaths
WHERE continent is not null
order by 1, 2


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
FROM ProjectPortfolio.dbo.CovidDeaths as dea
JOIN ProjectPortfolio.dbo.CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
FROM ProjectPortfolio.dbo.CovidDeaths as dea
JOIN ProjectPortfolio.dbo.CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac
WHERE RollingPeopleVaccinated is NOT NULL

-- TEMP TABLE

DROP TABLE if exists #PercentPopuVac
CREATE TABLE #PercentPopuVac (
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric)

Insert into #PercentPopuVac
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
FROM ProjectPortfolio.dbo.CovidDeaths as dea
JOIN ProjectPortfolio.dbo.CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date

--Creating View to store data for later visualizations

Create View PercentPopuVacci as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
FROM ProjectPortfolio.dbo.CovidDeaths as dea
JOIN ProjectPortfolio.dbo.CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null