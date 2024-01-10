
SELECT * FROM NashvilleHousing ; 

------------------------------------------
-- 1.Standardize Date Format

SELECT  SaleDate, CONVERT(date , SaleDate) FROM NashvilleHousing ; 


-- 2.If it doesn't Update properly

ALTER TABLE NashvilleHousing 
ADD ConvertedDate date  ;

Update NashvilleHousing
SET ConvertedDate = Convert(Date,SaleDate);



-- 3.Populate Property Address data
--SELECT a.[UniqueID ]  , a.ParcelID , a.PropertyAddress  , b.ParcelID , b.PropertyAddress , ISNULL(a.PropertyAddress, b.PropertyAddress ) RequiredAddress
--FROM NashvilleHousing a
--JOIN NashvilleHousing b ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
--WHERE a.PropertyAddress is NULL;


Update a
Set a.PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress )
FROM NashvilleHousing a
JOIN NashvilleHousing b ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL;
; 




-- 4.Breaking out Address into Individual Columns (Address, City, State)

--SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address , 
--SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))  AS State  FROM NashvilleHousing ;

ALTER TABLE NashvilleHousing
ADD PropertyAdress VARCHAR(250) , PropertyCity VARCHAR(70) 


UPDATE NashvilleHousing
SET PropertyAdress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);

UPDATE NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) ;

SELECT UniqueID , PropertyAdress , PropertyCity FROM NashvilleHousing; 

--4.1 Breaking out Address into Individual Columns (Address, City, State) -- OWNERSADDRESS

SELECT 
PARSENAME(REPLACE(OwnerAddress ,',' , '.'),1) as Address ,
PARSENAME(REPLACE(OwnerAddress ,',' , '.'),2) as City ,
PARSENAME(REPLACE(OwnerAddress ,',' , '.'),3) as State 
FROM NashvilleHousing 
Where PARSENAME(REPLACE(OwnerAddress ,',' , '.'),1) is not null; 

ALTER TABLE NashvilleHousing
ADD SplitOwnersAddress VARCHAR(250) , SplitOwnersCity VARCHAR(70) , SplitOwnersState VARCHAR(250)


UPDATE NashvilleHousing
SET SplitOwnersAddress = PARSENAME(REPLACE(OwnerAddress ,',' , '.'),1);

UPDATE NashvilleHousing
SET  SplitOwnersCity = PARSENAME(REPLACE(OwnerAddress ,',' , '.'),2) ;

UPDATE NashvilleHousing
SET  SplitOwnersState = PARSENAME(REPLACE(OwnerAddress ,',' , '.'),3) ;


UPDATE NashvilleHousing
SET SplitOwnersState = ISNULL(SplitOwnersAddress, 'NA') ;


select * from NashvilleHousing
WHERE SplitOwnersState <>'NA';




-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT * FROM NashvilleHousing;

SELECT distinct soldasvacant from NashvilleHousing;

UPDATE  NashvilleHousing
SET SoldAsVacant = 'Yes'
where SoldAsVacant like 'y';

UPDATE  NashvilleHousing
SET SoldAsVacant = 'No'
where SoldAsVacant = 'n';




-- Change Yes and No to Y and N in "Sold as Vacant" field Using Case Statement 

SELECT SoldAsVacant ,
case 
	WHEN SoldAsVacant = 'Yes' then 'Y'
	WHEN SoldAsVacant = 'No' then 'N'
end
FROM NashvilleHousing;

Update NashvilleHousing
SET SoldAsVacant = case 
	WHEN SoldAsVacant = 'Yes' then 'Y'
	WHEN SoldAsVacant = 'No' then 'N'
end

Select * from NashvilleHousing;




-- Remove Duplicates

Select * ,
ROW_NUMBER() 
OVER(partition by 
ParcelID,
PropertyAddress, 
SaleDate,
SalePrice, 
LegalReference
ORDER BY UniqueId
) as row_num 
from NashvilleHousing;

WITH ROWNUMCTE AS (
	Select * ,
ROW_NUMBER() 
OVER(partition by 
ParcelID,
PropertyAddress, 
SaleDate,
SalePrice, 
LegalReference
ORDER BY UniqueId
) as row_num from NashvilleHousing
)
DELETE FROM ROWNUMCTE
WHERE ROW_NUM > 1;



