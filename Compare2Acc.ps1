#  OFFICE 365 - COMPARE USERS AND GROUP WITH TWO DIFFERENT ACCOUNTS

################################################################################################

# Save in membersListcompanyA the members of group CompanyA
# connect CompanyA before run the script below

if ( -not $companyACredential ) {
    $companyACredential = Get-Credential -Message "Credential CompanyA"
    $userscompanyA = Get-MsolUser -All
    $GroupscompanyA = Get-MsolGroup -All

}

$membersListcompanyA = New-Object System.Data.DataTable
$column2 = New-Object System.Data.DataColumn("Name")
$column3 = New-Object System.Data.DataColumn("Email")
$membersListcompanyA.Columns.Add($column2)
$membersListcompanyA.Columns.Add($column3)
foreach($group in Get-MsolGroup -All){
    $members = Get-MsolGroupMember -GroupObjectId $group.ObjectId -All
    foreach($member in $members){
        try {
            $dataTable = $membersListcompanyA.NewRow()
            $dataTable["Name"] = $group.DisplayName
            $dataTable["Email"] = ($member.EmailAddress).Split('@')[0]
            $membersListcompanyA.Rows.Add($dataTable)
        }
        catch {
            Write-Host "Group without member"
        }
    }
}
$membersListcompanyA

###########################################################################################################

# Save in membersListCompB the members of group CompanyB
# connect CompanyB account before run the script below

if ( -not $companyBCredential ) {
    $companyBCredential = Get-Credential -Message "Credential CompanyB"
    $usersCompanyB = Get-MsolUser -All
    $GroupsCompanyB = Get-MsolGroup -All

}

$membersListCompB = New-Object System.Data.DataTable
$column2 = New-Object System.Data.DataColumn("Name")
$column3 = New-Object System.Data.DataColumn("Email")
$membersListCompB.Columns.Add($column2)
$membersListCompB.Columns.Add($column3)
foreach($group in Get-MsolGroup -All){
    $members = Get-MsolGroupMember -GroupObjectId $group.ObjectId -All
    foreach($member in $members){
        try {
            $dataTable = $membersListCompB.NewRow()
            $dataTable["Name"] = $group.DisplayName
            $dataTable["Email"] = ($member.EmailAddress).Split('@')[0]
            $membersListCompB.Rows.Add($dataTable)
        }
        catch {
        }
    }
}
$membersListCompB


############################################################################################################

# Check which users of CompanyB doesnt exist in CompanyA

$i=0
$j=0
$CompBwithoutCompA = 0 
foreach ($usuarioCompB in $usersCompanyB){
    $nomeCompB = ($usuarioCompB.UserPrincipalName).Split('@')[0]
    foreach ($usuariocompanyA in $userscompanyA){
        $nomecompanyA = ($usuariocompanyA.UserPrincipalName).Split('@')[0]
        if($nomeCompB -eq $nomecompanyA){
            $i=1
            break
        }
    }
    if($i -eq 0){
        if($j -eq 0){
            $CompBwithoutCompA = "`n" + $usuarioCompB.UserPrincipalName + "`n"
            $j++
        }
        else{
            $CompBwithoutCompA += $usuarioCompB.UserPrincipalName + "`n"
        }
    }
    $i=0
}
$CompBwithoutCompA


########################################################################################################

<#
Check the equivalent group of CompanyA and CompanyB;
Check the CompanyB and CompanyA group of each group
Save the members that dont exist in the CompanyB but exist in CompanyA
Save the members that dont exist in the CompanyA but exist in CompanyB
#>

$membersCompBNotCompanyA = New-Object System.Data.DataTable
$columnCompB1 = New-Object System.Data.DataColumn("Group")
$columnCompB2 = New-Object System.Data.DataColumn("Email without @")
$membersCompBNotCompanyA.Columns.Add($columnCompB1)
$membersCompBNotCompanyA.Columns.Add($columnCompB2)

$memberscompanyANotCompB = New-Object System.Data.DataTable
$columnBu1 = New-Object System.Data.DataColumn("Group")
$columnBu2 = New-Object System.Data.DataColumn("Email without @")
$memberscompanyANotCompB.Columns.Add($columnBu1)
$memberscompanyANotCompB.Columns.Add($columnBu2)

foreach ($groupCompB in $GroupsCompanyB) {
    if ($GroupscompanyA.DisplayName -contains $groupCompB.DisplayName){
     #   $idcompanyA = ($GroupscompanyA | Where-Object -Property DisplayName -EQ $groupCompB.DisplayName).ObjectId

        $membersGroupAtualcompanyA = $membersListcompanyA | where-Object {$_.Name -like $groupCompB.DisplayName}
        $membersGroupAtualCompB = $membersListCompB | Where-Object {$_.Name -like $groupCompB.DisplayName}
        
        foreach($memberCompB in $membersGroupAtualCompB) {
            if($membersGroupAtualcompanyA.Email -notcontains $memberCompB.Email){
                $dataTable = $membersCompBNotCompanyA.NewRow()
                $dataTable["Group"] = $groupCompB.DisplayName
                $dataTable["Email without @"] = $memberCompB.Email
                $membersCompBNotCompanyA.Rows.Add($dataTable)
            }
        }

        foreach($membercompanyA in $membersGroupAtualcompanyA) {
            if($membersGroupAtualCompB.Email -notcontains $membercompanyA.Email){
                $dataTable = $memberscompanyANotCompB.NewRow()
                $dataTable["Group"] = $groupCompB.DisplayName #os groups CompanyB e CompanyA sao os mesmos
                $dataTable["Email without @"] = $membercompanyA.Email
                $memberscompanyANotCompB.Rows.Add($dataTable)
            }
        }
    }
}
$membersCompBNotCompanyA
$memberscompanyANotCompB

#############################################################################################################