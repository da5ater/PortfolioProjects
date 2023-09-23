/*
cleaning data
*/


select * 
from portofolio.dbo.NashHousing;


/*
standarize date
*/

select SaleDate, convert(date,SaleDate)
from portofolio.dbo.NashHousing;
/*
update portofolio.dbo.NashHousing
set SaleDate = convert(date,SaleDate);
*/

ALTER TABLE NashHousing
add UpdatedDate date;

update portofolio.dbo.NashHousing
set UpdatedDate = convert(date,SaleDate);

select UpdatedDate , SaleDate
from portofolio.dbo.NashHousing;

-----------------------------



/* populate Property address data
*/

select *
from portofolio.dbo.NashHousing
 where PropertyAddress is null
order by ParcelID;

/* if 2 rows have the same parcelid , one of them has null-> assign the value of the cell with no null to the value of the cell with null ^-^
*/

select a.ParcelID , b.ParcelID, a.[UniqueID ], b.[UniqueID ], a.PropertyAddress , b.PropertyAddress
from portofolio.dbo.NashHousing a
join portofolio.dbo.NashHousing b
on a.ParcelID = b.ParcelID
where a.[UniqueID ] <> b.[UniqueID ]
and
a.PropertyAddress is null
order by a.ParcelID;


update a
set a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from portofolio.dbo.NashHousing a
join portofolio.dbo.NashHousing b
on a.ParcelID = b.ParcelID
where a.[UniqueID ] <> b.[UniqueID ]
and
a.PropertyAddress is null

------------------------------------------------
/* splitting adress into individual columns */

select PropertyAddress
from portofolio.dbo.NashHousing


select SUBSTRING(PropertyAddress , 1, CHARINDEX(',',PropertyAddress)-1)
, SUBSTRING(PropertyAddress ,CHARINDEX(',',PropertyAddress) +1 ,LEN(PropertyAddress))
from portofolio.dbo.NashHousing


-- creating address column
ALTER TABLE NashHousing
add SplitAddress nvarchar(255);

update portofolio.dbo.NashHousing
set SplitAddress = SUBSTRING(PropertyAddress , 1, CHARINDEX(',',PropertyAddress)-1);

-- creating city column
ALTER TABLE NashHousing
add SplitCity nvarchar(255);

update portofolio.dbo.NashHousing
set SplitCity = SUBSTRING(PropertyAddress ,CHARINDEX(',',PropertyAddress) +1 ,LEN(PropertyAddress));


-- splitting OwnerAddress column

select 
PARSENAME(replace(OwnerAddress, ',', '.'),3),
PARSENAME(replace(OwnerAddress, ',', '.'),2),
PARSENAME(replace(OwnerAddress, ',', '.'),1)
from portofolio.dbo.NashHousing


ALTER TABLE NashHousing
add SplitOwnerAddress nvarchar(255);

update portofolio.dbo.NashHousing
set SplitOwnerAddress = PARSENAME(replace(OwnerAddress, ',', '.'),3);

ALTER TABLE NashHousing
add SplitOwnerCity nvarchar(255);

update portofolio.dbo.NashHousing
set SplitOwnerCity = PARSENAME(replace(OwnerAddress, ',', '.'),2);


ALTER TABLE NashHousing
add SplitOwnerState nvarchar(255);

update portofolio.dbo.NashHousing
set SplitOwnerState = PARSENAME(replace(OwnerAddress, ',', '.'),1);

/* change Y and N to Yes and No */

select SoldAsVacant,
case when SoldAsVacant ='Y' then 'Yes'
	 when SoldAsVacant ='N' then 'No'
	 else SoldAsVacant
	 end
from portofolio.dbo.NashHousing

update portofolio.dbo.NashHousing
set SoldAsVacant = case when SoldAsVacant ='Y' then 'Yes'
	 when SoldAsVacant ='N' then 'No'
	 else SoldAsVacant
	 end;


-----------------------------------------
/* Delete duplicates*/

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

From portofolio.dbo.NashHousing
--order by ParcelID
)select *
From RowNumCTE
Where row_num > 1
 Order by PropertyAddress


 ---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From portofolio.dbo.NashHousing


ALTER TABLE portofolio.dbo.NashHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate















-----------------------------------------------------------------------------------------------