select * from HouseDbCleaning.dbo.[NashvilleHousing ]


-----------------Standardize Date Format------------------

select SaleDate,Convert(date,SaleDate)as converted
from HouseDbCleaning.dbo.[NashvilleHousing ]

Update [NashvilleHousing ] 
SET SaleDate=Convert(Date,SaleDate)

--alternate method : create a new column in the table 
-- and then update the new column with the converted data type

alter table [NashvilleHousing ]
add SaleDateCoverted Date;

update [NashvilleHousing ]
set SaleDateCoverted=Convert(Date,SaleDate)



---------Populate Property Address Data----------------


select *
from 
HouseDbCleaning.dbo.[NashvilleHousing ]
--where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from 
HouseDbCleaning.dbo.[NashvilleHousing ] a 
join HouseDbCleaning.dbo.[NashvilleHousing ] b
on a.ParcelID=b.ParcelID 
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null 


update a
set PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
from 
HouseDbCleaning.dbo.[NashvilleHousing ] a 
join HouseDbCleaning.dbo.[NashvilleHousing ] b
on a.ParcelID=b.ParcelID 
and a.[UniqueID ]<>b.[UniqueID ]




------Breaking Address into Individual Columns (Address,City,States)

select PropertyAddress from HouseDbCleaning.dbo.NashvilleHousing

select 
substring(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,charindex(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address
from HouseDbCleaning.dbo.NashvilleHousing
--setting up new columns 
alter table [NashvilleHousing ]
add PropertySplitAddress nvarchar(255);

update [NashvilleHousing ]
set PropertySplitAddress=substring(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1)



alter table [NashvilleHousing ]
add PropertySplitCity  nvarchar(255);

update [NashvilleHousing ]
set PropertySplitCity=SUBSTRING(PropertyAddress,charindex(',',PropertyAddress)+1,LEN(PropertyAddress))



select OwnerAddress
from HouseDbCleaning..NashvilleHousing

--parse name does things in backward manner
select 
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
From HouseDbCleaning.dbo.NashvilleHousing


alter table [NashvilleHousing ]
add OwnerSplitAddress  nvarchar(255);
update [NashvilleHousing ]
set OwnerSplitAddress =PARSENAME(Replace(OwnerAddress,',','.'),3)



alter table [NashvilleHousing ]
add OwnerSplitCity  nvarchar(255);

update [NashvilleHousing ]
set OwnerSplitCity =PARSENAME(Replace(OwnerAddress,',','.'),2)



alter table [NashvilleHousing ]
add OwnerSplitState  nvarchar(255);

update [NashvilleHousing ]
set OwnerSplitState=PARSENAME(Replace(OwnerAddress,',','.'),1)


select * from NashvilleHousing



----------------------------------------------------------------------------
--change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant),count(SoldAsVacant)
from NashvilleHousing 
group by SoldAsVacant


select SoldAsVacant
,case when SoldAsVacant='Y' then 'Yes'
when SoldAsVacant='N' then 'No'
else SoldAsVacant
end
from NashvilleHousing 


update NashvilleHousing 
set SoldAsVacant = case when SoldAsVacant='Y' then 'Yes'
when SoldAsVacant='N' then 'No'
else SoldAsVacant
end

select distinct(SoldAsVacant),count(SoldAsVacant)
from NashvilleHousing 
group by SoldAsVacant






-----Removing Duplicates--------
with RowNumCTE as(
select *,
ROW_NUMBER() over (
partition by ParcelID , 
PropertyAddress, 
SalePrice, 
SaleDate, 
LegalReference
order by UniqueID)row_num
from NashvilleHousing
--order by ParcelID
)

delete  from RowNumCTE 
where row_num>1



--Delete Unused Columns 
select * from 
NashvilleHousing

alter table NashvilleHousing 
drop column OwnerAddress,TaxDistrict,PropertyAddress
