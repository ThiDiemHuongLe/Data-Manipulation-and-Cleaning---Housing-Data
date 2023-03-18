Select *
from NashvilleHousing

/*1. Formatting sale date into YYYY-MM-DD*/
Alter table NashvilleHousing  /*In SQL, to add an extra column, we use Alter table*/
Add SaleDateConverted date

Update NashvilleHousing
Set SaleDateConverted=convert(date, SaleDate)

Select *
from NashvilleHousing

/*2.Populate property address*/
Select *
from NashvilleHousing
where PropertyAddress is Null

/*Fact is that when ParcelID is same, then Property address will be same.
Based on that, we can check parcelID of null address, then copy
property address of non-missing on into missing ones*/

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
Isnull (a.PropertyAddress,b.PropertyAddress) /*This statement is to check if
Property address in table a is actually Null, if yes, then populate 
Property address from table b*/
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <>b.[UniqueID ] /*to filter out NULL property address in both tables - no use*/
where a.PropertyAddress is null

Update a
set PropertyAddress = Isnull (a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <>b.[UniqueID ] 
where a.PropertyAddress is null
/*Now, mission is complete - all null are cleared*/

/*3. Seperate Property Address into individual columns of Address, City, State*/
Select PropertyAddress
from NashvilleHousing

/*Remove comma at the end of address + split address into two parts
- We use substring(var,1,3) - looking at var from position 1 and take letter number 3
- We use charindex to search for a certain character and here we look for
comma in PropertyAddress - this returns a position
- We go back one position by doing -1 - this helps remove comma
- Next, again, we use substring with same logic, starting one position after
comma and take the len of PropertyAddress - this returns City in seperate column*/

Select Substring (PropertyAddress, 1,charindex (',', PropertyAddress) -1) as Address
, Substring (PropertyAddress,charindex (',', PropertyAddress) + 1, Len(PropertyAddress)) as Address
from NashvilleHousing

/*We add new column named PropertySplitAddress to contain new the splited data*/
Alter table NashvilleHousing  
Add PropertySplitAddress nvarchar(255)

Update NashvilleHousing
Set PropertySplitAddress=Substring (PropertyAddress, 1,charindex (',', PropertyAddress) -1)

/*Again, add a new column for city*/
Alter table NashvilleHousing  
Add Property_City nvarchar(255)

Update NashvilleHousing
Set Property_City=Substring(PropertyAddress,charindex (',', PropertyAddress) + 1, Len(PropertyAddress))
 
/*Check the table at the end, we now splitted city and address into two parts
. This would be much more useful to draw insights from data*/
Select *
from NashvilleHousing

/*4. Now we split Address, City, State into 3 parts from OwnerAddress variable*/
Select OwnerAddress
from NashvilleHousing

Select 
parsename (replace(Owneraddress,',','.'), 3) ,
parsename (replace(Owneraddress,',','.'), 2) ,
parsename (replace(Owneraddress,',','.'), 1) 
from NashvilleHousing

/*Parsename is working with period, not comma. Hence, we need to
replace comma into '.'*/

Alter table NashvilleHousing  
Add OnwnerSplitAddress nvarchar(255)

Update NashvilleHousing
Set OnwnerSplitAddress=parsename (replace(Owneraddress,',','.'), 3)



Alter table NashvilleHousing  
Add OnwnerSplitCity nvarchar(255)

Update NashvilleHousing
Set OnwnerSplitCity=parsename (replace(Owneraddress,',','.'), 2)


Alter table NashvilleHousing  
Add OnwnerSplitState nvarchar(255)

Update NashvilleHousing
Set OnwnerSplitState=parsename (replace(Owneraddress,',','.'), 1)

Select *
from NashvilleHousing

/*5. Change Y to Yes and N to No om SoldAsVacant var*/
/*See breakdowns of Y,N,Yes,No under var SoldAsVacant*/
Select Distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant,
Case
	When SoldAsVacant='Y' then 'Yes'
	When SoldAsVacant='N' then 'No'
	Else SoldAsVacant
End
from NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant= Case
					When SoldAsVacant='Y' then 'Yes'
					When SoldAsVacant='N' then 'No'
					Else SoldAsVacant
					End
/*Check if values are updated*/
Select Distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2


/*6. Remove duplicates - The idea it that  a property must have unique Saledata,
property address, legalreference => if all those are same, then those are duplicates
and unusable and should be removed.
- To identify duplicates - we use Row_Number and Partition
*/
WITH RowNumCTE as (
Select *,
	Row_number() over (
	Partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				order by UniqueID
				) row_num
from NashvilleHousing
)

DELETE
from RowNumCTE
where row_num > 1

Select*
from RowNumCTE
where row_num > 1
order by PropertyAddress /*No more duplicate hence nothing returns*/

/*7. Delete unused columns*/
Select *
from NashvilleHousing

Alter table NashvilleHousing
Drop column OwnerAddress,
			TaxDistrict,
			PropertyAddress

Alter table NashvilleHousing
Drop column SaleDate
