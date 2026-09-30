---
name: jira-ticket
description: Use when the user asks to create a Jira ticket, issue, story, or task. Provides the description template and field defaults (assignee, priority, status, label).
---

# Jira ticket creation

When asked to create a Jira ticket, use this description structure:

```
## User story

<E.g.
As an Account Guardian
I want to …
So that I'm able to …
>

## Acceptance criteria

<Criteria 1>

<Criteria 2>

## Prototype links

<If there are links to prototypes, add them here>

## Necessary context

<External dependencies. Conversations, contacts, links to documentation>
```

Field defaults:

- **Assignee**: leave unassigned, unless a specific assignee is requested.
- **Priority**: Medium, unless otherwise specified.
- **Status**: after creating the issue, transition it to "Ready" (new issues default to "To Do", which sits in a board's Backlog column/tab and can be invisible on the main board view).
- **Label**: Use the existing "Assortment" label unless other is specified.

Be as concise and specific as possible. Keep it short, but still descriptive enough to understand. Do not fill the ticket with bloat.

If there are e.g. no prototype links or necessary context to fill out, remove the header.
