--SELECT *
--FROM portfolio1..CovidDeaths
--ORDER BY 3,4

--SELECT *
--FROM portfolio1..CovidVaccinations
--ORDER BY 3,4 -- по алфавиту 3 и 4 столбцы
-- Выберем данные которые будем использовать
--SELECT location, date, total_cases, new_cases, total_deaths, population
--FROM portfolio1..CovidDeaths
--ORDER BY 1,2

--сравним total_cases и total_deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM portfolio1..CovidDeaths
where location like 'Rus%'
ORDER BY 1,2
--сравниваем число случаев на население
SELECT location, date, total_cases, population, (total_cases/population)*100 as GotPercentage
FROM portfolio1..CovidDeaths
--where location like 'Ru%'
ORDER BY 1,2
--ищем страну с наибольшим процентом заражения
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM portfolio1..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC
-- HIGHEST DEATH COUNT
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From portfolio1..CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc
--ПО КОТИНЕНТАМ
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From portfolio1..CovidDeaths
Where continent iS null 
Group by location
order by TotalDeathCount desc

-- CONTINENTS WITH THE HIGHEST DEATH COUNT
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From portfolio1..CovidDeaths
Where continent iS NOT null 
Group by continent
order by TotalDeathCount desc

--GLOBAL DATA
SELECT SUM(new_cases) AS TOTAL_CASES, SUM(CAST(NEW_DEATHS AS INT)) AS TOTAL_DEATHS, SUM(CAST(NEW_DEATHS AS INT))/SUM(NEW_CASES)*100 AS DEATHPERCENTAGE
From portfolio1..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

--TOTAL POP VS VAC
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
FROM portfolio1..CovidDeaths DEA
JOIN portfolio1..CovidVaccinations VAC
ON DEA.location = VAC.location AND DEA.DATE = VAC.DATE
WHERE DEA.continent IS NOT NULL
ORDER BY 2, 3
--
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, SUM(CAST(VAC.new_vaccinations AS BIGINT)) OVER (PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION, DEA.DATE) AS RollingPeopleVaccinated
FROM portfolio1..CovidDeaths DEA
JOIN portfolio1..CovidVaccinations VAC
ON DEA.location = VAC.location AND DEA.DATE = VAC.DATE
WHERE DEA.continent IS NOT NULL
ORDER BY 2, 3
--GET THE PERCENT OF VACCINATED POPULATION WITH CTE
WITH PopvsVac (CONTINENT, LOCATION, DATE, POPULATION, NEW_VACCINATIONS, RollingPeopleVaccinated)
AS 
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, SUM(CAST(VAC.new_vaccinations AS BIGINT)) OVER (PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION, DEA.DATE) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/DEA.population)*100
FROM portfolio1..CovidDeaths DEA
JOIN portfolio1..CovidVaccinations VAC
ON DEA.location = VAC.location AND DEA.DATE = VAC.DATE
WHERE DEA.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/POPULATION)*100
FROM PopvsVac

--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
Create TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, SUM(CAST(VAC.new_vaccinations AS BIGINT)) OVER (PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION, DEA.DATE) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/DEA.population)*100
FROM portfolio1..CovidDeaths DEA
JOIN portfolio1..CovidVaccinations VAC
ON DEA.location = VAC.location AND DEA.DATE = VAC.DATE
--WHERE DEA.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/POPULATION)*100
FROM #PercentPopulationVaccinated

--CREATING VIEW TO STORE DATA FOR FUTURE VISUALIZATION
CREATE VIEW PercentPopulationVaccinated AS 
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, SUM(CAST(VAC.new_vaccinations AS BIGINT)) OVER (PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION, DEA.DATE) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/DEA.population)*100
FROM portfolio1..CovidDeaths DEA
JOIN portfolio1..CovidVaccinations VAC
ON DEA.location = VAC.location AND DEA.DATE = VAC.DATE
WHERE DEA.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *
FROM PercentPopulationVaccinated
ORDER BY 2, 3

--CREATING VIEW TO STORE DATA FOR FUTURE VISUALIZATION
CREATE VIEW GlobalDeaths AS 
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From portfolio1..CovidDeaths
Where continent iS null 
Group by location
--order by TotalDeathCount desc
--ORDER BY 2, 3
SELECT *
FROM GlobalDeaths
ORDER BY TotalDeathCount DESC

--CREATING VIEW TO STORE DATA FOR FUTURE VISUALIZATION
CREATE VIEW GlobalDeaths AS 
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From portfolio1..CovidDeaths
Where continent iS null 
Group by location
--order by TotalDeathCount desc
--ORDER BY 2, 3
SELECT *
FROM GlobalDeaths
ORDER BY TotalDeathCount DESC
