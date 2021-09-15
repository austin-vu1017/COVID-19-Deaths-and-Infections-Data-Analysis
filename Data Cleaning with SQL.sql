-- CONVERT SALEDATE TO DATE INSTEAD OF DATE/TIME
SELECT SalesDate, CONVERT(Date, SaleDate)
FROM [Portfolio Project One]..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)	--SaleDate IS NO LONGER mm/dd/yyyy 00:00:00 FORMAT; CONVERTED TO mm/dd/yyyy

ALTER TABLE NashvilleHousing
ADD sales_date_converted DATE;	--NEW ATTRIBUTE ADDED TO TABLE

UPDATE NashvilleHousing
SET sales_date_converted = CONVERT(DATE, SaleDate)	--UPDATED TABLE WITH NEW ATTRIBUTE sales_date_converted


-- POPULATE PROPERTY ADDRESS DATA 
SELECT *
FROM [Portfolio Project One]..NashvilleHousing
-- WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) --ISNULL CREATED A COLUMN WITH ALL ADDRESSES THAT HAS MATCHING ParcelID OF 'NULL' PROPERTY ADDRESSES
FROM [Portfolio Project One]..NashvilleHousing a	--CREATED TWO TABLE AND JOINED THEM. 
JOIN [Portfolio Project One]..NashvilleHousing b
	ON a.ParcelID = b.ParcelID	--IF BOTH ParcelID MATCHES
	AND a.[UniqueID ] <> b.[UniqueID ]	--BOTH UniqueID ARE UNEQUAL
WHERE a.PropertyAddress IS NULL	--WHEN PropertyAddress OF TABLE A IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)	--ISNULL(a.PropertyAddress, b.PropertyAddress) IS SET AS THE NEW VALUE OF PropertyAddress. REMOVING 'NULL' VALUE	
FROM [Portfolio Project One]..NashvilleHousing a
JOIN [Portfolio Project One]..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


-- SEPARATE ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)
SELECT PropertyAddress
FROM [Portfolio Project One]..NashvilleHousing
-- WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as address --CHARINDEX TO USE ',' AS DELIMITER OF ADDRESS AND -1 TO REMOVE THE COMMA
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as address
FROM [Portfolio Project One]..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD property_split_address nvarchar(255)	--ADD NEW ATTRIBUTE property_split_address

UPDATE NashvilleHousing
SET property_split_address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)	--SET VALUE OF ATTRIBUTE property_split_address TO THE PROPERTY ADDRESS

ALTER TABLE NashvilleHousing
ADD property_split_city nvarchar(255)	--ADD NEW ATTRIBUTE property_split_city

UPDATE NashvilleHousing
SET property_split_city = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))	--SET VALUE OF ATTRIBUTE property_split_city TO THE CITY NAME

SELECT *	--CHECKING TABLE FOR NEWLY ADDED ATTRIBUTES
FROM [Portfolio Project One]..NashvilleHousing

SELECT OwnerAddress
FROM [Portfolio Project One]..NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)	--HOLDS STATE ATTRIBUTE. NUMBERS ARE REVERSED SO THEY CAN BE ADDED IN ORDER INTO THE TABLE
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)		--HOLDS CITY ATTRIBUTE
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)		--HOLDS ADDRESS ATTRIBUTE
FROM [Portfolio Project One]..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD owner_split_address nvarchar(255)	--ADD NEW ATTRIBUTE owner_split_address

UPDATE NashvilleHousing
SET owner_split_address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)	--SET VALUE OF ATTRIBUTE owner_split_address TO THE OWNER ADDRESS

ALTER TABLE NashvilleHousing
ADD owner_split_city nvarchar(255)	--ADD NEW ATTRIBUTE owner_split_city

UPDATE NashvilleHousing
SET owner_split_city = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)	--SET VALUE OF ATTRIBUTE owner_split_city TO THE CITY

ALTER TABLE NashvilleHousing
ADD owner_split_state nvarchar(255)	--ADD NEW ATTRIBUTE owner_split_state

UPDATE NashvilleHousing
SET owner_split_state = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)	--SET VALUE OF ATTRIBUTE owner_split_state TO THE STATE

SELECT *	--CHECKING TABLE FOR NEWLY ADDED ATTRIBUTES
FROM [Portfolio Project One]..NashvilleHousing


--CHANGE Y/N TO YES AND NO IN "SoldAsVacant" FIELD
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Portfolio Project One]..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant, 
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant 
	END
FROM [Portfolio Project One]..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = 
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant 
	END


--REMOVE DUPLICATES. DO NOT DELETE DATABASE IN ACTUAL PRACTICE
WITH remove_dup_cte AS	--CREATE CTE
(
	SELECT *,
		ROW_NUMBER() OVER 
		(
			PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference	--SEARCH FOR ALL THESE MATCHING ATTRIBUTES
			ORDER BY UniqueID	
		) row_num

	FROM [Portfolio Project One]..NashvilleHousing
)

--SELECT *	--DISPLAYING ALL DUPLICATE OBSERVATIONS
--FROM remove_dup_cte
--WHERE row_num > 1	--DUPLICATE OBSERVATIONS WILL BE MARKED 2 AND BE DELETED	
--ORDER BY PropertyAddress

--DELETE	--DELETE (!!!! DON'T DO THIS AN ACTUAL WORK DATABASE !!!!) ALL DUPLICATE WITH row_num GREATER THAN 2
--FROM remove_dup_cte
--WHERE row_num > 1

SELECT *	--CHECK IF DUPLICATES WERE PROPERLY DELETED
FROM remove_dup_cte
WHERE row_num > 1


--DELETE UNUSED COLUMNS
SELECT *	--CHECK FOR POSSIBLE UNNEEDED ATTRIBUTES
FROM [Portfolio Project One]..NashvilleHousing

ALTER TABLE [Portfolio Project One]..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate	--DROPPING THESE LISTED ATTRIBUTES AS THEY ARE NOT NEEDED ANYMORE

SELECT *	--CHECK IF PREVIOUS QUERY WORKS
FROM [Portfolio Project One]..NashvilleHousing

ALTER TABLE [Portfolio Project One]..NashvilleHousing
DROP COLUMN SaleDate	--DROPPING THESE LISTED ATTRIBUTES AS THEY ARE NOT NEEDED ANYMORE

SELECT *	--CHECK IF PREVIOUS QUERY WORKS
FROM [Portfolio Project One]..NashvilleHousing