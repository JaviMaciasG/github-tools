#!/bin/bash

# Get a list of all your repositories
echo "Fetching list of repositories..."
repos=$(gh repo list --limit 1000 --json nameWithOwner -q '.[].nameWithOwner')

echo "===================="
echo "Your Repositories"
echo "===================="
for repo in $repos; do
    echo "$repo"
done

# Loop through each repository to list collaborators and invitation status
for repo in $repos; do
    echo "----------------------------------------------------------------"
    echo "Repository: $repo"
    echo "----------------------------------------------------------------"

    # List collaborators
    echo "Collaborators:"
    collaborators=$(gh api repos/$repo/collaborators --paginate --jq '.[].login' | sort)
    if [ -z "$collaborators" ]; then
        echo "No collaborators found."
    else
        for collaborator in $collaborators; do
            echo "- $collaborator"
        done
    fi

    # Pending invites
    echo "Pending Invites:"
    pending_invites=$(gh api repos/$repo/invitations --jq '.[] | select(.expired == false) | {id: .id, invitee: (.invitee.login // "N/A"), email: (.email // "N/A")}')
    if [ -z "$pending_invites" ]; then
        echo "No pending invites."
    else
        echo "$pending_invites" | jq -r '. | "ID: \(.id), Invitee: \(.invitee), Email: \(.email)"'
    fi

    # Expired invites
    echo "Expired Invites:"
    expired_invites=$(gh api repos/$repo/invitations --jq '.[] | select(.expired == true) | {id: .id, invitee: (.invitee.login // "N/A"), email: (.email // "N/A")}')
    if [ -z "$expired_invites" ]; then
        echo "No expired invites."
    else
        echo "$expired_invites" | jq -r '. | "ID: \(.id), Invitee: \(.invitee), Email: \(.email)"'
    fi

    echo "----------------------------------------------------------------"
done

