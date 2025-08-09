param(
  [string]$OrgAlias = "dev"
)

$ErrorActionPreference = "Stop"

function Ensure-Folder {
  param([string]$Path)
  if (-not (Test-Path $Path)) { New-Item -ItemType Directory -Path $Path | Out-Null }
}

Write-Host "🔎 Checking Salesforce CLI..." -ForegroundColor Cyan
sf --version | Out-Null

# Make sure we're at the project root
Ensure-Folder "force-app\main\default"
Ensure-Folder "force-app\main\default\objects"

Write-Host "📦 Creating custom objects..." -ForegroundColor Cyan
sf force:object:create --label "Host Application" --plural "Host Applications" `
  --type "CustomObject" --deployment-status Deployed --sharing-model ReadWrite `
  --name Host_Application__c

sf force:object:create --label "Property" --plural "Properties" `
  --type "CustomObject" --deployment-status Deployed --sharing-model ReadWrite `
  --name Property__c

sf force:object:create --label "Room" --plural "Rooms" `
  --type "CustomObject" --deployment-status Deployed --sharing-model ReadWrite `
  --name Room__c

sf force:object:create --label "Listing" --plural "Listings" `
  --type "CustomObject" --deployment-status Deployed --sharing-model ReadWrite `
  --name Listing__c

Write-Host "🧱 Creating fields on Host_Application__c..." -ForegroundColor Cyan
sf force:field:create --object Host_Application__c --label "Status" --type Picklist `
  --picklist-values "Submitted;Under_Review;Approved;Rejected" --api-name Status__c

sf force:field:create --object Host_Application__c --label "First Name" --type Text --length 80 --api-name First_Name__c
sf force:field:create --object Host_Application__c --label "Last Name"  --type Text --length 80 --api-name Last_Name__c
sf force:field:create --object Host_Application__c --label "Email"      --type Email        --api-name Email__c
sf force:field:create --object Host_Application__c --label "Phone"      --type Phone        --api-name Phone__c

sf force:field:create --object Host_Application__c --label "Address" --type LongTextArea --length 32768 --visible-lines 3 --api-name Address__c
sf force:field:create --object Host_Application__c --label "Notes"   --type LongTextArea --length 32768 --visible-lines 3 --api-name Notes__c

sf force:field:create --object Host_Application__c --label "External Auth Subject" --type Text `
  --length 255 --unique --api-name External_Auth_Subject__c

Write-Host "🏠 Creating fields on Property__c..." -ForegroundColor Cyan
sf force:field:create --object Property__c --label "Host"     --type Lookup --reference-to Account --api-name Host__c
sf force:field:create --object Property__c --label "Street"   --type Text --length 255 --api-name Street__c
sf force:field:create --object Property__c --label "City"     --type Text --length 80  --api-name City__c
sf force:field:create --object Property__c --label "State"    --type Text --length 80  --api-name State__c
sf force:field:create --object Property__c --label "Postcode" --type Text --length 20  --api-name Postcode__c
sf force:field:create --object Property__c --label "Country"  --type Text --length 80  --api-name Country__c
sf force:field:create --object Property__c --label "Description"  --type LongTextArea --length 32768 --visible-lines 3 --api-name Description__c
sf force:field:create --object Property__c --label "House Rules"  --type LongTextArea --length 32768 --visible-lines 3 --api-name House_Rules__c

Write-Host "🛏️  Creating fields on Room__c..." -ForegroundColor Cyan
sf force:field:create --object Room__c --label "Property" --type MasterDetail --reference-to Property__c --api-name Property__c
sf force:field:create --object Room__c --label "Has Private Bathroom" --type Checkbox --default-value false --api-name Has_Private_Bathroom__c
sf force:field:create --object Room__c --label "Aircon" --type Checkbox --default-value false --api-name Aircon__c
sf force:field:create --object Room__c --label "Price Per Week" --type Currency --precision 16 --scale 2 --api-name Price_Per_Week__c
sf force:field:create --object Room__c --label "Capacity" --type Number --precision 3 --scale 0 --api-name Capacity__c

Write-Host "📣 Creating fields on Listing__c..." -ForegroundColor Cyan
sf force:field:create --object Listing__c --label "Room" --type MasterDetail --reference-to Room__c --api-name Room__c
sf force:field:create --object Listing__c --label "Status" --type Picklist --picklist-values "Draft;Published;Paused" --api-name Status__c
sf force:field:create --object Listing__c --label "Start Available" --type Date --api-name Start_Available__c
sf force:field:create --object Listing__c --label "Min Term Weeks" --type Number --precision 3 --scale 0 --api-name Min_Term_Weeks__c
sf force:field:create --object Listing__c --label "Amenities" --type MultiselectPicklist --picklist-values "WiFi;Desk;Heating;Aircon;Laundry" --api-name Amenities__c

# Tabs
Write-Host "🗂️  Creating object tabs..." -ForegroundColor Cyan
Ensure-Folder "force-app\main\default\tabs"

@"
<?xml version="1.0" encoding="UTF-8"?>
<CustomTab xmlns="http://soap.sforce.com/2006/04/metadata">
  <fullName>Host_Application__c</fullName>
  <label>Host Applications</label>
  <motif>Custom8: Diamond</motif>
</CustomTab>
"@ | Out-File -FilePath "force-app\main\default\tabs\Host_Application__c.tab-meta.xml" -Encoding utf8

@"
<?xml version="1.0" encoding="UTF-8"?>
<CustomTab xmlns="http://soap.sforce.com/2006/04/metadata">
  <fullName>Property__c</fullName>
  <label>Properties</label>
  <motif>Custom13: Box</motif>
</CustomTab>
"@ | Out-File -FilePath "force-app\main\default\tabs\Property__c.tab-meta.xml" -Encoding utf8

@"
<?xml version="1.0" encoding="UTF-8"?>
<CustomTab xmlns="http://soap.sforce.com/2006/04/metadata">
  <fullName>Room__c</fullName>
  <label>Rooms</label>
  <motif>Custom23: Anchor</motif>
</CustomTab>
"@ | Out-File -FilePath "force-app\main\default\tabs\Room__c.tab-meta.xml" -Encoding utf8

@"
<?xml version="1.0" encoding="UTF-8"?>
<CustomTab xmlns="http://soap.sforce.com/2006/04/metadata">
  <fullName>Listing__c</fullName>
  <label>Listings</label>
  <motif>Custom55: Books</motif>
</CustomTab>
"@ | Out-File -FilePath "force-app\main\default\tabs\Listing__c.tab-meta.xml" -Encoding utf8

# Permission Set
Write-Host "🔐 Creating Host_Admin permission set..." -ForegroundColor Cyan
Ensure-Folder "force-app\main\default\permissionsets"

@"
<?xml version="1.0" encoding="UTF-8"?>
<PermissionSet xmlns="http://soap.sforce.com/2006/04/metadata">
  <label>Host Admin</label>
  <hasActivationRequired>false</hasActivationRequired>

  <objectPermissions>
    <allowCreate>true</allowCreate><allowDelete>true</allowDelete>
    <allowEdit>true</allowEdit><allowRead>true</allowRead>
    <modifyAllRecords>true</modifyAllRecords><viewAllRecords>true</viewAllRecords>
    <object>Host_Application__c</object>
  </objectPermissions>

  <objectPermissions>
    <allowCreate>true</allowCreate><allowDelete>true</allowDelete>
    <allowEdit>true</allowEdit><allowRead>true</allowRead>
    <modifyAllRecords>true</modifyAllRecords><viewAllRecords>true</viewAllRecords>
    <object>Property__c</object>
  </objectPermissions>

  <objectPermissions>
    <allowCreate>true</allowCreate><allowDelete>true</allowDelete>
    <allowEdit>true</allowEdit><allowRead>true</allowRead>
    <modifyAllRecords>true</modifyAllRecords><viewAllRecords>true</viewAllRecords>
    <object>Room__c</object>
  </objectPermissions>

  <objectPermissions>
    <allowCreate>true</allowCreate><allowDelete>true</allowDelete>
    <allowEdit>true</allowEdit><allowRead>true</allowRead>
    <modifyAllRecords>true</modifyAllRecords><viewAllRecords>true</viewAllRecords>
    <object>Listing__c</object>
  </objectPermissions>

  <tabSettings><tab>Host_Application__c</tab><visibility>Visible</visibility></tabSettings>
  <tabSettings><tab>Property__c</tab><visibility>Visible</visibility></tabSettings>
  <tabSettings><tab>Room__c</tab><visibility>Visible</visibility></tabSettings>
  <tabSettings><tab>Listing__c</tab><visibility>Visible</visibility></tabSettings>
</PermissionSet>
"@ | Out-File -FilePath "force-app\main\default\permissionsets\Host_Admin.permissionset-meta.xml" -Encoding utf8

Write-Host "🚀 Deploying metadata to org '$OrgAlias'..." -ForegroundColor Cyan
sf project deploy start -o $OrgAlias

Write-Host "👤 Assigning Host_Admin to current user..." -ForegroundColor Cyan
sf org assign permset -o $OrgAlias -n Host_Admin

Write-Host "`n✅ Done. Objects, fields, tabs, and Host_Admin are ready in $OrgAlias." -ForegroundColor Green