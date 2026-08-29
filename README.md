# Portfolio

> [https://beck-chan.github.io/](https://beck-chan.github.io/)

A lovingly handed-coded portfolio, built on [Quarto](https://quarto.org/):

- Auto-rendered then deployed to the URL above via GitHub Pages by [deploy-site.yaml](https://github.com/beck-chan/portfolio/blob/main/.github/workflows/deploy-site.yaml).
- Release notes automatically generated upon PR merge into `main` by [generate-release.yaml](https://github.com/beck-chan/portfolio/blob/main/.github/workflows/generate-release.yaml)

### PRs 

PRs are required to merge changes into `main` to ensure that release notes are automatically generated:

- Relevant `.qmd`s in PRs automatically checked for spelling errors with [spellcheck.yaml](https://github.com/beck-chan/portfolio/blob/main/.github/workflows/spellcheck.yaml)
- Open PRs deploy a preview to [https://beckchan-staging.netlify.app/](https://beckchan-staging.netlify.app/) with [preview-site.yaml](https://github.com/beck-chan/portfolio/blob/main/.github/workflows/preview-site.yaml) &mdash; when the PR closes, the staging site is replaced by a redirect to the live site.

## Copyright

&#169; 2026 Beck Chan. All rights reserved.
