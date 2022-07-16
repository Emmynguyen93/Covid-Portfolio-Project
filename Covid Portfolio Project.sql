SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccination
--ORDER by 3,4

-- Select Data that I'm going to use

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country (ex:US)
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location like '%states%'
and continent is not null
ORDER by 1,2


--Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Where Location like '%states%'
ORDER by 1,2


--Looking at country with Highest Infection Rate compared to Population (sort descending)
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--Where Location like '%states%'
GROUP by Location, population
ORDER by PercentPopulationInfected desc


--Showing Countries with Highest Death Count per Population

SELECT Location, Max(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where Location like '%states%'
WHERE continent is not null
GROUP by Location
ORDER by TotalDeathCount desc


--Break things down by continent
--Showing continents with the highest death count per population

SELECT location, Max(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where Location like '%states%'
WHERE continent is null
GROUP by location
ORDER by TotalDeathCount desc



--Global numbers total cases/ death percent by date
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
WHERE continent is not null
GROUP by date
ORDER by 1,2


--Global total cases vs death - Death Percent Overall
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
WHERE continent is not null
--GROUP by date
ORDER by 1,2



--Looking at Total Population vs Vaccination (57:00)

--Use CTE
With PopvsVAc (Continent, Location, Date, Population, New_Vacinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, RollingPeopleVaccinated/ population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER by 2,3
)
SELECT *, (RollingPeopleVaccinated/ Population)*100
FROM PopvsVac



--TEMP TABLE

DROP table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, RollingPeopleVaccinated/ population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER by 2,3

SELECT *, (RollingPeopleVaccinated/ Population)*100
FROM #PercentPopulationVaccinated



-- Creating view to store data for later visualization

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, RollingPeopleVaccinated/ population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER by 2,3

SELECT *
FROM PercentPopulationVaccinated