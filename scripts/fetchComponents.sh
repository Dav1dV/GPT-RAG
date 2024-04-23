#!/bin/sh

repos_git_clone_arguments=(
    # Per-repository strings  of  repository-specific `git clone` arguments
    #   ending with the  Repository URL  with optional .git suffix,
    # including AT LEAST  3 strings
    #   ending with  EACH of the following repository/directory names  EXACTLY:
    #
    #     gpt-rag-ingestion
    #     gpt-rag-orchestrator
    #     gpt-rag-frontend
    https://github.com/Azure/gpt-rag-ingestion
    https://github.com/Azure/gpt-rag-orchestrator
    https://github.com/Azure/gpt-rag-frontend
)

#git_clone_options=--single-branch  # for all repositories

for repo_clone_args in "${repos_git_clone_arguments[@]}"; do

    echo

    # Delete the repository folder from .azure if it exists
    path=./.azure/$(basename --suffix=.git -- "$repo")
    #               e.g., gpt-rag-ingestion from https://github.com/Azure/gpt-rag-ingestion
    if [ -d    "$path" ]; then
        rm -rf "$path"
    fi

    # Clone the repository into the .azure folder
    git clone $git_clone_options $repo_clone_args "$path"
done