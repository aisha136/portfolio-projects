/*
Cleaning Data in SQL Queries
*/

Select * 
from NashvilleHousing

-------------------------------------------------------------------------------------------------------


--Standardize the Date Format

Select SaleDateConverted, CONVERT(Date, SaleDate)
from NashvilleHousing

ALTER Table NashvilleHousing
Add SaleDateConverted Date

UPDATE NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)


-------------------------------------------------------------------------------------------------------

--Populate Property Address Data

SELECT *
FROM NashvilleHousing
ORDER BY ParcelID


SELECT 
	A.ParcelID, 
	A.PropertyAddress, 
	B.ParcelID, 
	B.PropertyAddress, 
	ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM NashvilleHousing A
JOIN NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] != B.[UniqueID ]
WHERE A.PropertyAddress is null
	
	

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM NashvilleHousing A
JOIN NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] != B.[UniqueID ]
WHERE A.PropertyAddress is null

-------------------------------------------------------------------------------------------------------

--Break out PropertyAddress into individual columns (Address, City)

Select PropertyAddress
from NashvilleHousing


Select 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address, --Address
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
from NashvilleHousing



ALTER Table NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)



ALTER Table NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))



-------------------------------------------------------------------------------------------------------

--Break out OwnerAddress into individual columns (Address, City, State)

Select
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
From NashvilleHousing



ALTER Table NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)



ALTER Table NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)



ALTER Table NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



-------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" Column


SELECT 
	DISTINCT(SoldAsVacant), 
	COUNT(SoldASVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2



SELECT 
	SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
END
FROM NashvilleHousing	



UPDATE NashvilleHousing
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
END


-------------------------------------------------------------------------------------------------------

--Remove Duplicates


WITH RowNumCTE AS (
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
From NashvilleHousing
)


DELETE
FROM RowNumCTE
WHERE row_num > 1



-------------------------------------------------------------------------------------------------------

--Remove unused columns


ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

