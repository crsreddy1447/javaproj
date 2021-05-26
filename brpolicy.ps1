#What are branch policies?
#Branch policies help you protect important branches and enforce code quality. When a branch has a policy set to it, it is no longer possible to commit directly to it. All changes need to be done through a Pull Request (PR).
#There are different kind of policies that can be set up:

#Require a minimum number of reviewers
#Check for linked work items
#Check for comment resolution
#Limit merge types
#Build validation

##Status checks

[CmdletBinding()]
param (
    $orgUrl,
    $project,
    #$branch
    $approversId
)


write-host "($Env:system.collectionUri)"
write-host "($Env:system.teamProject)"

az devops login --organization $orgUrl #https://dev.azure.com/crsreddy1447
# set environment variable for current process
$env:AZURE_DEVOPS_EXT_PAT = 'a545rvhhznuf6ngn4m23w4gftsvkh2rte5tdgbyfbq6xngvig42a'

# $orgUrl = "$(orgurl)" # https://dev.azure.com/OrgName
# $project = "$(teamProject)"

# $repositories = @("sample-java-app.git")
 $branch = "test"
# $approversId = "$(approversId)"

foreach($repo in $repositories) {
    $repoId = (az repos show --org $orgUrl -p $project --repository $repo --query id -o tsv)
    echo "$repo has id: $repoId"

    $currentPolicies = (az repos policy list --org $orgUrl -p $project --repository-id $repoId --branch $branch --query [].type.displayName -o tsv)

    if ($currentPolicies -eq $null -Or !$currentPolicies.Contains("Minimum number of reviewers")) {
        echo "Creating minimum number of reviewers policy for $repo"
        az repos policy approver-count create --org $orgUrl -p $project --branch $branch --repository-id $repoId --allow-downvotes false --blocking true --creator-vote-counts true --enabled true --minimum-approver-count 2 --reset-on-source-push false -o none
    } else {
        echo "$repo already has minimum number of reviewers policy"
    }

    if ($currentPolicies -eq $null -Or !$currentPolicies.Contains("Comment requirements")) {
        echo "Creating comment requirements policy for $repo"
        az repos policy comment-required create --org $orgUrl -p $project --branch $branch --repository-id $repoId --blocking true --enabled true -o none
    } else {
        echo "$repo already has comment requirements policy"
    }

    # if ($currentPolicies -eq $null -Or !$currentPolicies.Contains("Work item linking")) {
    #     echo "Creating work item linking policy for $repo"
    #     az repos policy work-item-linking create --org $orgUrl -p $project --branch $branch --repository-id $repoId --blocking true --enabled true -o none
    # } else {
    #     echo "$repo already has work item linking policy"
    # }

    if ($currentPolicies -eq $null -Or !$currentPolicies.Contains("Required reviewers")) {
        echo "Creating required reviewers policy for $repo"
        az repos policy required-reviewer create --org $orgUrl -p $project --branch $branch --repository-id $repoId --blocking true --enabled true --message "PR Approvers" --required-reviewer-ids $approversId -o none
    } else {
        echo "$repo already has required reviewers policy"
    }
}

# https://docs.microsoft.com/en-us/azure/devops/repos/get-started/what-is-repos?view=azure-devops
# https://docs.microsoft.com/en-us/azure/devops/repos/git/branch-policies-overview?view=azure-devops
# https://docs.microsoft.com/en-us/cli/azure/repos/policy?view=azure-cli-latest

