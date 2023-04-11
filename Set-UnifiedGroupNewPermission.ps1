#region Configure these parameters

# Members are allowed to create M365 gorups
$allowedGroupName = "GroupCreators" 
# Disable creation of M365 groups for all other users
$allowGroupCreation = $false

#endregion

# Install the Azure AD Preview module
Install-Module -Name AzureADPreview

# Sign in to Azure AD
Connect-AzureAD

# Get the settings for Microsoft 365 Groups
$settingsObject = Get-AzureADDirectorySetting | 
    Where-object { $PSItem.Displayname -eq "Group.Unified" }

# If the settings are not present yet, create the settings
if(! $settingsObject){

    # Find the template for the Microsoft 365 Group settings
    $template = Get-AzureADDirectorySettingTemplate | 
        Where-Object {$PSItem.displayname -eq "group.unified"}

    # Create the settings object from the template and store it in Azure AD
    $settingsObject = $template.CreateDirectorySetting()
    New-AzureADDirectorySetting -DirectorySetting $settingsObject
}

# Allow or disallow group creation for all users
$settingsObject["EnableGroupCreation"] = $allowGroupCreation

# Allow creating of Microsoft 365 groups for members of a particular group
# This required Azure AD Premium P1!
$settingsObject["GroupCreationAllowedGroupId"] = `
    (Get-AzureADGroup -SearchString $allowedGroupName).objectid

# Save the settings
$settingsObject | Set-AzureADDirectorySetting

# Verify the settings
($settingsObject | Get-AzureADDirectorySetting).Values
