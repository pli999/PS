#Parameters
#$AdminCenterURL="https://crescent-admin.sharepoint.com"
#$UserAccount = "Salaudeen@Crescent.com" #UPN

$AdminCenterURL="https://connecthkuhk-my.sharepoint.com/personal/pclli_connect_hku_hk"
# $AdminCenterURL2="https://connecthkuhk-my.sharepoint.com"
$UserAccount = "pclli@connect.hku.hk" #UPN
 
Try {
    #Connect to Admin Center
#    Connect-PnPOnline -Url $AdminCenterURL
     
    #Get onedrive site URL of the user
#    $OneDriveURL = Get-PnPUserProfileProperty -Account $UserAccount | Select -ExpandProperty PersonalUrl
    $OneDriveURL = $AdminCenterURL

    If($OneDriveURL -ne $null)
    {
        #Connect to OneDrive site
        Connect-PnPOnline -Url $OneDriveURL
 
        #Get All items in the recycle bin
#        $RecycleBinItems = Get-PnPRecycleBinItem -RowLimit 500000
        $RecycleBinItems = Get-PnPRecycleBinItem -RowLimit 1
 
        $count = $RecycleBinItems.count

        #Check if there are any deleted items in recycle bins
        If($count -eq 0) {
            Write-host "No Items found in the recycle bin!" -f Yellow
            Write-Output "No Items found in the recycle bin!"
            Break
        }
 
        #Restore all items from the recycle bin
#        $RecycleBinItems = Get-PnPRecycleBinItem -RowLimit 500000
        $RecycleBinItems = Get-PnPRecycleBinItem | Sort-Object -Property DeletedDate -Descending
        $count = $RecycleBinItems.count

        $i = 0
        ForEach($Item in $RecycleBinItems)
        {
            $i = $i + 1
            Write-Host "$i/$count-" -NoNewline
            Write-Output "$i/$count-" -NoNewline

            #Get the Original location of the deleted file or folder
            $OriginalLocation = "/"+$Item.DirName+"/"+$Item.LeafName
#             Write-host "Item Location: '$OriginalLocation'" -f Yellow
            If($Item.ItemType -eq "File")
            {
                Write-host "File: '$OriginalLocation'" -f Yellow -NoNewline
                Write-Output "File: '$OriginalLocation'" -f -NoNewline
                $OriginalItem = Get-PnPFile -Url $OriginalLocation -AsListItem -ErrorAction SilentlyContinue
            }
            Else #Folder
            {
                Write-host "Folder: '$OriginalLocation'" -f Blue -NoNewline
                Write-Output "Folder: '$OriginalLocation'" -NoNewline
                $OriginalItem = Get-PnPFolder -Url $OriginalLocation -ErrorAction SilentlyContinue
            }
            #Check if the item exists in the original location
            If($OriginalItem -eq $null)
            {
                #Restore the item
                Restore-PnPRecycleBinItem -Identity $Item -Force
#                Write-host "Restored Item '$($Item.LeafName)' to '$($Item.DirName)'" -f Green
                Write-host "- Restored" -f Green
                Write-Output "- Restored"

            }
            Else
            {
                Write-Host "Item Exists!" -f Red
                Write-Output "Item Exists!"
#                Write-Host "A file or folder with this name $($Item.LeafName) already exists in '$($Item.DirName)', Skipping.."  -f Red
            }
        }
    }
    Else
    {
        Write-host "OneDrive site for the user doesn't exist!" -f Yellow
        Write-Output "OneDrive site for the user doesn't exist!"
    }
}
Catch {
    Write-host "Error: $($_.Exception.Message)" -foregroundcolor Red
    Write-Output "Error: $($_.Exception.Message)"
}


#Read more: https://www.sharepointdiary.com/2021/06/powershell-to-restore-all-files-and-folder-from-onedrive-for-business-recycle-bin.html#ixzz8PzqFrpHU