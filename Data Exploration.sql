SELECT *
FROM [Portfolio Project One]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4


-- SELECT LOCATION, DATE, TOTAL_CASES, NEW_CASES, TOTAL_DEATHS, AND POPULATION ATTRIBUTES AND ORDER BY LOCATION (1) THEN DATE (2)
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project One]..CovidDeaths
ORDER BY 1, 2


-- TOTAL CASES vs. TOTAL DEATH; LIKELIHOOD OF DYING IF CONTRACTED COVID
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM [Portfolio Project One]..CovidDeaths
WHERE location like '%states%'
ORDER BY 1, 2


-- TOTAL CASES vs. POPULATION; HOW MUCH BY PERCENTAGE DOES THE POPULATION HAVE COVID OVERTIME
SELECT location, population, date, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as infected_percentage
FROM [Portfolio Project One]..CovidDeaths
GROUP BY location, population, date
ORDER BY infected_percentage DESC


-- COUNTRY WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
SELECT location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as infected_percentage
FROM [Portfolio Project One]..CovidDeaths
-- WHERE location like '%states%'
GROUP BY location, population
ORDER BY infected_percentage DESC


-- COUNTRY WITH HIGHEST DEATH COUNT PER POPULATION
SELECT continent, MAX(cast(total_deaths AS INT)) AS highest_death_count
FROM [Portfolio Project One]..CovidDeaths
-- WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY highest_death_count DESC


-- GLOBAL NUMBERS

-- TOTAL NEW CASES AND DEATHS AROUND THE WORLD WITH DEATH PERCENTAGE PER DAY
SELECT date, SUM(new_cases) AS total_new_cases, SUM(cast(new_deaths AS INT)) AS total_new_deaths, SUM(cast(new_deaths AS INT))/SUM(new_cases)*100 AS death_percentage
FROM [Portfolio Project One]..CovidDeaths
-- WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2


-- TOTAL NEW CASES AND DEATHS WITH CURRENT DEATH PERCENTAGE AS OF 9/13/21
SELECT SUM(new_cases) AS total_new_cases, SUM(cast(new_deaths AS INT)) AS total_new_deaths, SUM(cast(new_deaths AS INT))/SUM(new_cases)*100 AS death_percentage
FROM [Portfolio Project One]..CovidDeaths
-- WHERE location like '%states%'
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1, 2


-- TOTAL DEATH IN EVERY CONTINENT EXCLUDING World, EU, and International attributes
SELECT location, SUM(convert(int, new_deaths)) as total_death_count
FROM [Portfolio Project One]..CovidDeaths
WHERE continent IS NULL AND	location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY total_death_count DESC


-- QUERIES FROM THEN ON WILL BE FOR COVID VACCINATION TABLE


-- TOTAL POPULATION vs. VACCINATION
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
, (rolling_people_vaccinated/population)*100

FROM [Portfolio Project One]..CovidDeaths dea
JOIN [Portfolio Project One]..CovidVaccinations vac
		ON dea.location = vac.location
		and dea.date = vac.date 
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3


-- CTE	
WITH population_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated) AS
(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated

	FROM [Portfolio Project One]..CovidDeaths dea
	JOIN [Portfolio Project One]..CovidVaccinations vac
			ON dea.location = vac.location
			and dea.date = vac.date 
	WHERE dea.continent IS NOT NULL
)

SELECT *, (rolling_people_vaccinated/population)*100
FROM population_vs_vac


--TEMP TABLE
DROP TABLE IF EXISTS #percent_population_vaccinated
CREATE TABLE #percent_population_vaccinated
(
	continent nvarchar(255), location nvarchar(255), data datetime, population numeric, new_vaccination numeric, rolling_people_vaccinated numeric
)

INSERT INTO #percent_population_vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
FROM [Portfolio Project One]..CovidDeaths dea
JOIN [Portfolio Project One]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
				
SELECT *, (rolling_people_vaccinated/population)*100
FROM #percent_population_vaccinated


--CREATE VIEW FOR STORING DATA FOR VISUALIZATION
CREATE VIEW percent_population_vaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated

FROM [Portfolio Project One]..CovidDeaths dea
JOIN [Portfolio Project One]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date 
WHERE dea.continent IS NOT NULL

SELECT *
FROM percent_population_vaccinated
