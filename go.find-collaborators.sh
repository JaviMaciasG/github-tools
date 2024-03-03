#!/bin/bash

# Initialize variables for command-line arguments
repo_name=""
visibility_flag=""

# Parse command-line options
while getopts ":r:" opt; do
  case ${opt} in
    r )
      repo_name=$OPTARG
      ;;
    \? )
        echo "Invalid option: $OPTARG" 1>&2
        echo "Usage: $0 [-r repository_name] (if not provided, process all available repos)"
        exit 1
      ;;
    : )
        echo "Invalid option: $OPTARG requires an argument" 1>&2
        exit 1
      ;;
  esac
done
shift $((OPTIND -1))


# Fetch list of repositories with visibility (isPrivate flag)
if [[ -n "$repo_name" ]]; then
    # Fetch information for a single repository if specified
    echo "Fetching info on $repo_name..."
    repos=$(gh repo view "$repo_name" --json nameWithOwner,isPrivate -q '"\(.nameWithOwner) \(.isPrivate)"')
else
    # Fetch list of all repositories with visibility (isPrivate flag)
    echo "Fetching list of repositories..."
    repos=$(gh repo list --limit 1000 --json nameWithOwner,isPrivate -q '.[] | "\(.nameWithOwner) \(.isPrivate)"')
fi

echo "===================="
echo "Your Repositories"
echo "===================="
# Display each repo with its visibility
index=0
for repo_info in $repos; do
    if (( $index % 2 == 0 )); then
        repo=$(echo "$repo_info" | cut -d ' ' -f 1)
    else
        visibility=$(echo "$repo_info" | cut -d ' ' -f 1)
        if [ "$visibility" = "true" ]; then
            visibility="private"
        else
            visibility="public"
        fi
        echo "$repo ($visibility)"
    fi
    ((index++))
done

echo "Processing each repository..."
index=0
repo=""
for repo_info in $repos; do
    if (( $index % 2 == 0 )); then
        repo=$repo_info
    else
        visibility=$repo_info
        if [ "$visibility" = "true" ]; then
            visibility="private"
        else
            visibility="public"
        fi

        echo "----------------------------------------------------------------"
        echo "Repository: $repo ($visibility)"
        echo "----------------------------------------------------------------"

        # List collaborators with commit counts
        echo "Collaborators:"
        collaborators=$(gh api repos/$repo/collaborators --paginate --jq '.[].login' | sort)
        if [ -z "$collaborators" ]; then
            echo "No collaborators found."
        else
            for collaborator in $collaborators; do
                # Fetch the number of commits for each collaborator and sum them
                commits=$(gh api repos/$repo/commits --paginate --jq "[.[] | select(.author.login==\"$collaborator\")] | length" | paste -sd+ - | bc)
                echo "- $collaborator (Commits: $commits)"
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
    fi
    ((index++))
done

