Select * From portfolioproject.dbo.coviddeaths
order by 3,4

Select * From portfolioproject..covidvaccination order by 3,4;

Select Location, date, total_cases, new_cases, total_deaths, population
From portfolioproject..coviddeaths order by 2;

--Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage 
From portfolioproject..coviddeaths
where location like 'india'
order by 5 desc;


--Looking at Total Cases vs Population

select location,date,total_cases,population
from portfolioproject..coviddeaths
where location like 'india'
order by 1,2

--Looking at countries with highest infection rate compared to population

select location, Population, MAX(total_cases) as HighestInfection, Max((total_cases/population))*100 as DeathPercentage
from portfolioproject..coviddeaths 
where location like 'india'
group by location,population
order by DeathPercentage desc

--Showing Countries with highest death count per population

select location, population, MAX(cast (total_deaths as int)) as highestdeath
from portfolioproject..coviddeaths
where continent is not null
group by location, population
order by highestdeath desc

--Showing by Continent
select continent, MAX(cast (total_deaths as int)) as highestdeath
from portfolioproject..coviddeaths
where continent is not null
group by continent
order by highestdeath desc

--Global Numbers

select date,sum(new_cases) as total_new_cases,sum(cast(new_deaths as int)) as total_new_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From portfolioproject..coviddeaths
where continent is not null 
group by date
order by 1,2




select * from portfolioproject..covidvaccination

select *
from portfolioproject..coviddeaths dea
join portfolioproject..covidvaccination vac
on dea.location = vac.location
and dea.date = vac.date

--Total population vs vacnination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--Use CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..coviddeaths dea
Join PortfolioProject..Covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



--Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view for later visulization

create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select * from PercentPopulationVaccinated