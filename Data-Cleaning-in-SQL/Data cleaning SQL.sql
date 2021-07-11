/*
Cleaning Data in SQL Queries
*/


select * from portfolioproject..nashville order by 1

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

select saledate, convert(date,saledate)
from portfolioproject..nashville

update nashville
set SaleDate= convert(date,SaleDate)

ALTER TABLE nashville
add SaleDateConverted Date;

update nashville
set SaleDateConverted = convert(date,SaleDate)

select SaleDateConverted from portfolioproject..nashville

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select *
from portfolioproject..nashville
where PropertyAddress is null

select a.ParcelID, a.PropertyAddress, b.parcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
from portfolioproject..nashville a
join portfolioproject..nashville b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is not null

update a
set PropertyAddress = ISNULL(a.propertyaddress, b.PropertyAddress)
from portfolioproject..nashville a
join portfolioproject..nashville b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from portfolioproject..nashville

select SUBSTRING(propertyaddress,1,CHARINDEX(',', propertyaddress)-1) as address,
SUBSTRING(propertyaddress,CHARINDEX(',', propertyaddress)+1, LEN(propertyaddress)) as city
from portfolioproject..nashville

ALTER TABLE nashville
add PropertyAddressSplit nvarchar(255);

update nashville
set PropertyAddressSplit = SUBSTRING(propertyaddress,1,CHARINDEX(',', propertyaddress)-1) 

ALTER TABLE nashville
add City nvarchar(255);

update nashville
set City = SUBSTRING(propertyaddress,CHARINDEX(',', propertyaddress)+1, LEN(propertyaddress))

select
PARSENAME(replace(owneraddress,',','.'),3)
,PARSENAME(replace(owneraddress,',','.'),2)
,PARSENAME(replace(owneraddress,',','.'),1)
from portfolioproject..nashville

ALTER TABLE nashville
add OwnerAddressSplit nvarchar(255);

update nashville
set OwnerAddressSplit = PARSENAME(replace(owneraddress,',','.'),3)

ALTER TABLE nashville
add OwnerAddressCity nvarchar(255);

update nashville
set OwnerAddressCity = PARSENAME(replace(owneraddress,',','.'),2)

ALTER TABLE nashville
add OwnerAddressState nvarchar(255);

update nashville
set OwnerAddressState = PARSENAME(replace(owneraddress,',','.'),1)




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(soldasvacant)
from portfolioproject..nashville
group by SoldAsVacant
order by 2

select SoldAsVacant
,Case	when SoldAsVacant= 'Y' then 'Yes'
		when SoldAsVacant= 'N' then 'No'
		else SoldAsVacant
		END
from portfolioproject..nashville

update nashville
set SoldAsVacant =Case when SoldAsVacant= 'Y' then 'Yes'
	when SoldAsVacant= 'N' then 'No'
	else SoldAsVacant
	END 

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.Nashville
--order by ParcelID
)
select *
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

select * from portfolioproject..nashville order by 1

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From PortfolioProject.dbo.Nashville


ALTER TABLE PortfolioProject.dbo.Nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

















-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO