### Repository Name: SSH Setup Scripts

#### Description:

This repository contains a collection of scripts designed to automate the generation and management of SSH keys for various version control systems like GitHub, GitLab, and Bitbucket. These scripts simplify the setup process, enhance security, and ensure that your development environment is quickly replicable.

#### Scripts Included:

1.  setup_ssh_for_github.sh

    -   Automates the creation of SSH keys specifically configured for GitHub accounts. It adds the SSH key to your GitHub via the API if desired.
2.  setup_ssh_for_gitlab.sh

    -   Similar to the GitHub script, it automates SSH key creation and configuration for GitLab and offers the option to upload the key directly to your GitLab account using the GitLab API.
3.  setup_ssh_for_bitbucket.sh

    -   This script generates and configures an SSH key for use with Bitbucket. It also includes functionality to add the SSH key to your Bitbucket account through the Bitbucket API.
4.  generate_ssh_key.sh

    -   A generic script for creating SSH keys that supports multiple cryptographic algorithms. It can be used for general purposes where specific version control configurations are not required.

#### How to Use:

To use any of these scripts, follow these steps:

1.  Clone this repository to your local machine.
2.  Navigate to the repository directory in your terminal.
3.  Set the script you want to use as executable. For example:

    bash

    Copy code

    `chmod +x setup_ssh_for_github.sh`

4.  Run the script from your terminal. For example:

    bash

    Copy code

    `./setup_ssh_for_github.sh`

5.  Follow the on-screen prompts to complete the setup process.

#### Requirements:

-   Linux OS or a Unix-like environment
-   `curl` and `xclip` installed on your machine
-   Personal access tokens from your version control system with appropriate permissions to add SSH keys

#### Security Notes:

-   Always keep your private keys secure and never share them.
-   Regularly update and rotate your SSH keys as part of your security best practices.
-   Use strong, unique passphrases for your SSH keys.

#### Additional Information:

Feel free to modify and adapt these scripts to fit your specific requirements or security protocols. Contributions to improve the functionality or security of these scripts are welcome.
