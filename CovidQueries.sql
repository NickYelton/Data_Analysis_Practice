--Viewing each data set
SELECT *
FROM COVID_Data..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM COVID_Data..CovidVaccinations
--ORDER BY 3,4


--Selecting specific data to view/use
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM COVID_Data..CovidDeaths
ORDER BY 1,2

--Total Cases vs. Total Deaths in the U.S.
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM COVID_Data..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--Total Cases vs. Population
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PopTotal
FROM COVID_Data..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2

--Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as Highest_Infection, MAX((total_cases/population))*100 AS Percent_Pop_Infected
FROM COVID_Data..CovidDeaths
GROUP BY population, continent
ORDER BY Percent_Pop_Infected DESC

--Continent with Highest Death Count per Population
SELECT continent, MAX(CAST(total_deaths as INT)) AS Highest_Death_Count
FROM COVID_Data..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Highest_Death_Count DESC

--Global Numbers
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as INT)) AS total_deaths, 
	SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 as DeathPercentage
FROM COVID_Data..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--View Vaccinations
SELECT *
FROM COVID_Data..CovidVaccinations
ORDER BY 3,4

--Total Population vs. Total Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS People_Vaxed
FROM COVID_Data..CovidDeaths dea
JOIN COVID_Data..CovidVaccinations vacc
	ON dea.location = vacc.location
	AND dea.date = vacc.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


--Create CTE
WITH Pop_vs_Vacc (continent, location, date, population, new_vaccinations, People_Vaxed) AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS People_Vaxed
FROM COVID_Data..CovidDeaths dea
JOIN COVID_Data..CovidVaccinations vacc
	ON dea.location = vacc.location
	AND dea.date = vacc.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (People_Vaxed/population)*100 AS total_vax
FROM Pop_vs_Vacc


--Create view for data visualization
CREATE VIEW Pop_vs_Vacc AS
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS People_Vaxed
FROM COVID_Data..CovidDeaths dea
JOIN COVID_Data..CovidVaccinations vacc
	ON dea.location = vacc.location
	AND dea.date = vacc.date
WHERE dea.continent IS NOT NULL

