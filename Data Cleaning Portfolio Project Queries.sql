Select *
From PortfolioProject..NashvilleHousing

--Standardize Date Format
Select SaleDateConverted, CONVERT(Date, SaleDate) 
From PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE PortfolioProject..NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate) 

--Populate Property Address data
Select *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) 
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ] 
Where a.PropertyAddress is null

Update a 
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ] 
Where a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)
Select PropertyAddress
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) 

Select *
From PortfolioProject..NashvilleHousing

Select OwnerAddress 
From PortfolioProject..NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) 

ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From PortfolioProject..NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" field
Select Distinct(SoldAsVacant), COUNT(SoldAsVacant) 
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
From PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

-- Remove Duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID 
					 ) row_num
From PortfolioProject..NashvilleHousing
--Order by ParcelID
)
Select *
From RowNumCTE 
Where row_num > 1
Order by PropertyAddress

Select *
From PortfolioProject..NashvilleHousing

-- Delete Unused Columns
Select *
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioProject..NashvilleHousing
Drop Column SaleDate