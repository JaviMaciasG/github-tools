# GitHub Repository Manager Script

This script is designed to interact with GitHub repositories, providing a command-line interface to fetch and display repository information, including visibility (public/private), collaborators, pending invitations, and expired invitations. It utilizes the GitHub CLI (`gh`) to perform its operations.

## Features

- **List All Repositories**: Fetches all repositories for the authenticated user, displaying their name and visibility status.
- **List Collaborators**: For each repository, lists all collaborators along with the count of commits they have made.
- **Pending Invitations**: Displays any pending invitations for each repository.
- **Expired Invitations**: Shows any expired invitations for each repository.

## Prerequisites

- GitHub CLI (`gh`) must be installed and configured for the target GitHub account.
- Bash shell environment.

## Usage

```bash
./github_repo_manager.sh [OPTIONS]
```

### Options

- `-r`, `--repo <repository>`: Specify a single repository by its name. If not provided, the script will process all repositories.
- `--public`: Filter and show information only for public repositories.
- `--private`: Filter and show information only for private repositories.

### Examples

- List all repositories:

```bash
./github_repo_manager.sh
```

- List information for a specific repository:

```bash
./github_repo_manager.sh -r <repository_name>
```

## Note

Ensure that you have the necessary permissions to access the information of the repositories you want to manage with this script.

