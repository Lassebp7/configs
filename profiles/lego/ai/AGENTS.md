# Git

## Creating branches

When creating a new branch for a change, create them following this convention:

- `feat/ASM-XXXX-<feature-summary>` - For branches creating new features. Only include the ASM-XXXX part if a jira ticket has been referenced in the conversation already. Do not go and search for a related ticket if one hasn't already been referenced.
- `fix/ASM-XXXX-<fix-summary>` - For branches with fixes to existing features. Only include the ASM-XXXX part if a jira ticket has been referenced in the conversation already. Do not go and search for a related ticket if one hasn't already been referenced.
- `chore/<chore-summary>` - For chore tasks, such as dependabot fixes, version bumps and so forth.

## Pull Request Template

When creating a pull request, fill out the template below as the PR description.

```txt
## Summary

Type a short summary of the overall changes in pull request here...

## Changes

- _Added a pull request template_
- _Fixed documentation folder_
- _Some other change..._

## Checklist:

I have...
- [ ] ... performed a self-review of my code
- [ ] ... commented my code, particularly in hard-to-understand areas
- [ ] ... added unit tests to relevant business logic
- [ ] ... updated relevant documentation in the /docs folder
- [ ] ... merged with the latest `main` branch and fixed conflicts
```
