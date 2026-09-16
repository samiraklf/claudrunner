---
name: security-sweep
description: "Language-agnostic security and vulnerability pass over a diff or a codebase. Covers injection, authorization, tenant isolation, secrets, deserialization, request forgery, output escaping and dependency risk. Use for a security review, a vulnerability hunt, or before exposing a new endpoint. Triggers on 'security', 'vulnerability', 'is this safe', 'audit'."
---

# Security sweep

Find the holes. Report only what you can prove from the code.

## Scope

Given a diff, review the diff and everything it reaches. Given a codebase, start at the
boundaries: every route, handler, message consumer, scheduled job, webhook and file upload.

## What to hunt

**Injection.** Any query, command, path, template or markup assembled from input that a
user influences. Parameter binding is the fix; escaping is not. Look for string
concatenation into a query builder as often as raw statements.

**Authorization.** Every endpoint answers three questions: is the caller authenticated, are
they permitted to do this, and are they permitted to do it *to this object*. The third is
the one that gets missed. An identifier accepted from a URL or body, then used without an
ownership check, is the most common real breach in a business application.

**Tenant isolation.** In any system with more than one customer, every read and write on
customer-owned data must be scoped to the caller's tenant, derived from the session — never
from a parameter the caller supplies.

**Secrets.** Credentials, tokens and keys in source, in fixtures, in test files, in logs, in
error messages, in client-side bundles. Check what the logger records on failure.

**Mass assignment.** Any path where a whole request body becomes a record's fields.

**Deserialization and templating.** Untrusted input reaching a deserializer, a template
engine, an expression evaluator, or a dynamic import.

**Request forgery.** Outbound requests to a user-supplied address. Internal metadata
endpoints and private address ranges are the target.

**Output.** Anything rendered without escaping, and anything that disables escaping
deliberately.

**Dependencies.** New dependencies in the diff: who publishes it, how many releases, and
whether it does what its name says.

## Reporting

Use the `card-format` skill. For each finding add:

- **Reachability** — the concrete path from an external actor to the vulnerable line. A
  finding that no input can reach is a P2 hygiene note, not a vulnerability.
- **Severity** — Critical means exploitable now with real consequence. Reserve it.

Never write a working exploit. Describe the class, the path and the fix.

If a finding looks like an active exposure — a live credential, an open data path — stop
the sweep and tell the user immediately, before finishing the rest.
