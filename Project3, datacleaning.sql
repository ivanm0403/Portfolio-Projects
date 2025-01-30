SELECT *
FROM portfolio1..housing
--приведение даты к стандартнму виду
SELECT SaleDateConverted, convert(Date, saledate)
FROM portfolio1..housing

update housing
set saledate = SaleDateConverted

alter table housing
add SaleDateConverted Date;
update housing
set SaleDateConverted = convert(Date, saledate)

-- заполняем все адреса покупки, где parcellid совпадают но адрес только один
SELECT *
FROM portfolio1..housing
where PropertyAddress is null


--SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress) 
--FROM portfolio1..housing a
--join portfolio1..housing b
--on a.ParcelID = b.ParcelID
--and a.[UniqueID ] <> b.[UniqueID ] --не равно
--where a.PropertyAddress is null

--update a
--set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress) 
--FROM portfolio1..housing a
--join portfolio1..housing b
--on a.ParcelID = b.ParcelID
--and a.[UniqueID ] <> b.[UniqueID ] --не равно

--разделение адреса в три столбца, разделение через запятую
SELECT PropertyAddress
FROM portfolio1..housing

select
substring(propertyaddress, 1, charindex(',', propertyaddress) -1) as Address,
substring(propertyaddress, charindex(',', propertyaddress) +1, len(PropertyAddress)) as Address
FROM portfolio1..housing

alter table portfolio1..housing
add PropertySplitAddress Nvarchar(255);
update portfolio1..housing
set PropertySplitAddress = substring(propertyaddress, 1, charindex(',', propertyaddress) -1)

alter table portfolio1..housing
add PropertySplitCity Nvarchar(255);
update portfolio1..housing
set PropertySplitCity = substring(propertyaddress, charindex(',', propertyaddress) +1, len(PropertyAddress))

-- меняем адрес владельца

select OwnerAddress
FROM portfolio1..housing

select
parsename(replace(OwnerAddress, ',', '.'), 3),
parsename(replace(OwnerAddress, ',', '.'), 2),
parsename(replace(OwnerAddress, ',', '.'), 1)
FROM portfolio1..housing
 
 ALTER TABLE portfolio1..housing
Add OwnerSplitAddress Nvarchar(255);

Update portfolio1..housing
SET OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.'), 3)


ALTER TABLE portfolio1..housing
Add OwnerSplitCity Nvarchar(255);

Update portfolio1..housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE portfolio1..housing
Add OwnerSplitState Nvarchar(255);

Update portfolio1..housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

--
SELECT distinct(SoldAsVacant) -- ЕСТЬ N Y, МЕНЯЕМ НА YES NO
FROM portfolio1..housing 

SELECT distinct(SoldAsVacant), COUNT(SOLDASVACANT)
FROM portfolio1..housing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	  WHEN SoldAsVacant = 'N' THEN 'NO'
	  ELSE SoldAsVacant
	  END
FROM portfolio1..housing

UPDATE portfolio1..housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	  WHEN SoldAsVacant = 'N' THEN 'NO'
	  ELSE SoldAsVacant
	  END

-- НАХОДИМ ДУБЛИКАТЫ
WITH ROWNUMCTE AS(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY PARCELID, PROPERTYADDRESS, SALEPRICE, SALEDATE,LEGALREFERENCE
ORDER BY UNIQUEID) ROW_NUM
FROM portfolio1..housing
)
SELECT *
FROM ROWNUMCTE
WHERE ROW_NUM > 1
ORDER BY PropertyAddress
-- УДАЛЯЕМ ИХ
WITH ROWNUMCTE AS(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY PARCELID, PROPERTYADDRESS, SALEPRICE, SALEDATE,LEGALREFERENCE
ORDER BY UNIQUEID) ROW_NUM
FROM portfolio1..housing
)
DELETE
FROM ROWNUMCTE
WHERE ROW_NUM > 1


WITH ROWNUMCTE AS(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY PARCELID, PROPERTYADDRESS, SALEPRICE, SALEDATE,LEGALREFERENCE
ORDER BY UNIQUEID) ROW_NUM
FROM portfolio1..housing
)
SELECT *
FROM ROWNUMCTE
WHERE ROW_NUM > 1

--УДАЛЯЕМ НЕНУЖНЫЕ СТОЛБЦЫ

ALTER TABLE portfolio1..housing
DROP COLUMN OWNERADDRESS, TAXDISTRICT, PROPERTYADDRESS

SELECT *
FROM portfolio1..housing

ALTER TABLE portfolio1..housing
DROP COLUMN SALEDATE