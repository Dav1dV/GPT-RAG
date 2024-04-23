#!/usr/bin/env pwsh

$reposGitCloneArguments = @(
    # Per-repository strings  of  repository-specific `git clone` arguments
    #   ending with the  Repository URL  with optional .git suffix,
    # including AT LEAST  3 strings
    #   ending with  EACH of the following repository/directory names  EXACTLY:
    #
    #     gpt-rag-ingestion
    #     gpt-rag-orchestrator
    #     gpt-rag-frontend
    'https://github.com/Azure/gpt-rag-ingestion',
    'https://github.com/Azure/gpt-rag-orchestrator',
    'https://github.com/Azure/gpt-rag-frontend'
)

#$gitCloneOptions = '--single-branch'  # for all repositories

foreach ($repoCloneArgs in $reposGitCloneArguments) {

    ''

    # Delete the repository folder from .azure if it exists
    path = "./.azure/$(Split-Path -LeafBase $repoCloneArgs)"
    #                  e.g., gpt-rag-ingestion from https://github.com/Azure/gpt-rag-ingestion
    if (Test-Path -PathType Container  $path) {
        Remove-Item -Recurse -Force    $path
    }

    # Clone the repository into the .azure folder
    Invoke-Expression "git clone $gitCloneOptions $repoCloneArgs '$path'"
}