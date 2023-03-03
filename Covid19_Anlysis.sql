# 1. Find total cases, total deaths and compare them as a percentage

SELECT 
    SUM(total_cases) AS Total_cases,
    SUM(CAST(total_deaths AS UNSIGNED)) AS Total_deaths,
    ROUND(SUM(CAST(total_deaths AS UNSIGNED)) / SUM(total_cases) * 100,
            2) AS DeathPercentage
FROM
    Covid19.coviddeath
WHERE
    Continent IS NOT NULL
ORDER BY 1 , 2;
# Total_cases	Total_deaths	DeathPercentage
# 760246281673	10119542809		1.33

#2. Return the total number highest deaths by location .
SELECT 
    location,
    MAX(CAST(Total_deaths AS UNSIGNED)) AS HighestTotalDeaths
FROM
    Covid19.coviddeath
GROUP BY location
ORDER BY HighestTotalDeaths DESC;
# location, highest_total_deaths
#Europe			2027927
#North America	1578525
#South America	1348348
#European Union	1210781
#United States	1115564
#Brazil			697904
#India			530757
#Russia			387689
#Mexico			332695
#Africa			57654

#3. Finding the total, cases, total deaths and Deathpercentage by location of each year
Select Location, date, total_cases,total_deaths, ROUND((total_deaths/total_cases)*100,2) as DeathPercentage
From Covid19.coviddeath
order by 1,2;

#4. What is the total number of deaths, total cases, and total vacinations in each continent?
SELECT 
    d.continent,
    SUM(CAST(d.total_cases AS UNSIGNED)) AS total_cases,
    SUM(CAST(d.total_deaths AS UNSIGNED)) AS total_deaths,
    SUM(CAST(v.total_vaccinations AS UNSIGNED)) AS total_vaccinations
FROM
    Covid19.coviddeath d
        JOIN
    Covid19.covidvacination v ON d.location = v.location
        AND d.date = v.date
WHERE
    d.continent IS NOT NULL
GROUP BY d.continent;
# continent		total_cases		total_deaths	total_vaccinations
#Asia			43275939490		584962556		1172192993925
#Africa			4855011203		127722212		31636897410
#North America 5350515684		250255337		46969773602
#South America 5270996454		142172196		30637944738
#Europe		522134855			15971562		366721186
#Oceania	6099083				46834			14088284

#5 Find the highest infection percent rate by location
SELECT 
    location,
    MAX(total_cases) AS HighestInfectionRate,
    population,
    ROUND(MAX((total_cases / population)) * 100, 2) AS PercentageInfectionRate
FROM
    Covid19.coviddeath
GROUP BY location , population
ORDER BY PercentageInfectionRate DESC;
# location	HighestInfectionRate	population	PercentageInfectionRate
#Cyprus			645515				896007			72.04
#San Marino		23494				33690			69.74
#Austria		5843614				8939617			65.37
#Faeroe Islands	34658				53117			65.25
#Slovenia		1324603				2119843			62.49


#6. Total new deaths in United States
Select location, population, SUM(cast(new_deaths AS UNSIGNED)) as TotalDeathCount
From Covid19.coviddeath
Where location like '%states%'
#Where continent is null 
Group by location, population
order by TotalDeathCount desc;
# location, 		population, TotalDeathCount
#'United States', '338289856', '1116074'

#7.Finds the percentage of highest infection by date in USA
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Covid19.coviddeath
Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc;
# Location		Population		date	HighestInfectionCount	PercentPopulationInfected
#United States	338289856	2/15/23		102995115				30.4500
#United States	338289856	2/14/23		102912933				30.4200
#United States	338289856	2/13/23		102878993				30.4100
#United States	338289856	2/12/23		102857632				30.4100
#United States	338289856	2/11/23		102855163				30.400

#8.Finds the percentage of Death Rate by Year in USA
Select Location, date, total_cases,total_deaths, ROUND((total_deaths/total_cases)*100,2) as DeathPercentage
From Covid19.coviddeath
Where location like '%states%'
#where continent is not null 
order by 1,2 ASC;
# Location		date	total_cases	total_deaths	DeathPercentage
# United States	1/1/21	20397389	352804			1.73
# United States	1/1/22	55099825	825907			1.5
# United States	1/1/23	100768720	1092846			1.08
# United States	1/10/21	22613186	379717			1.68
# United States	1/10/22	61923604	840897			1.36
# United States	1/10/23	101398439	1097077			1.08
# United States	1/11/21	22817687	381567			1.67
# United States	1/11/22	62709815	843418			1.34
# United States	1/11/23	101538088	1098901			1.08
# United States	1/12/21	23040103	385916			1.67


#9. Finding the how many people Vacinated by location
Select dea.continent, dea.location, dea.date, dea.population
, MAX(vac.total_vaccinations) as RollingPeopleVaccinated
#(RollingPeopleVaccinated/population)*100
From Covid19.coviddeath dea
Join Covid19.covidvacination vac
	On dea.location = vac.location
	and dea.date = vac.date
#where dea.continent is not null
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2,3;

#10 FIND percentage Fully Vacinated by Location
SELECT 
    D.Location, D.continent,
    D.Population,
    MAX(CAST(V.people_fully_vaccinated AS UNSIGNED)) AS Max_vaccinated,
    ROUND(MAX(CAST(V.people_fully_vaccinated AS UNSIGNED)) / MAX(CAST(population AS UNSIGNED)) * 100,
            2) AS MaxPercent_vaccinated
FROM
    Covid19.coviddeath AS D
        JOIN
    Covid19.covidvacination AS V ON D.Location = V.Location
        AND D.DATE = V.DATE
GROUP BY D.Location , D.Population, D.continent
ORDER BY MaxPercent_vaccinated DESC;
## Location	Population	max_vaccinated	maxPercent_vaccinated
##Vietnam	98186856	85705657			87.29
##Ecuador	18001002	14214551			78.97
##Costa Rica 5180836	4290783				82.82
##Cambodia	16767851	14607080			87.11
##Bhutan	782457		677669				86.61 


#11. Overall percentage people vacinated by Year, location
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Covid19.coviddeath dea
Join Covid19.covidvacination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
#order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac




