# Agent Instructions

Before starting any task in this repository:

1. Run `make agents/sync`. It writes the shared Plus3 IT instructions for this repository's tardigrade-ci version to `.agents/plus3it/AGENTS.md`.
2. Read `.agents/plus3it/AGENTS.md` and follow it together with this file. If the sync fails, tell the user, and don't guess the conventions.

These rules always apply, even without the shared instructions:

- Don't push, open pull requests, publish releases, or apply infrastructure changes unless the user asks. List those steps for a person in your final report.
- Don't edit files under `.agents/plus3it/`; they are generated and overwritten by the sync.

@.agents/plus3it/AGENTS.md

## Repository-specific

### Purpose

This Terraform module creates an S3 bucket and the optional configurations attached to it. The bucket name is set with the `bucket` input; versioning, server-side encryption, ownership controls, and the public access block are applied by default, and the other features (logging, CORS, replication, lifecycle rules, policy, grants, notifications, and more) are turned on by setting their inputs. It outputs the bucket as `bucket`, plus `public_access_block` and `notification`.

### Module-specific files

- `data.tf` — Looks up the canonical user ID (only when `grants` is set) and defines the default bucket policy used when `policy.json` is null
- `tests/*/templates/` — JSON policy templates used by some test scenarios
- `tests/create_notifications/lambda.py` — Test fixture: handler for the Lambda function that the notifications scenario uses as a notification target, not module source
- `tests/create_notifications/builds/` — Zip package of that fixture, committed to the repository

### Deviations from the terraform-module profile

- `test.yml` and `release.yml` pass `mockstacktest-pytest-args` to the shared workflow, which deselects the `create_request_payment`, `create_intelligent_tiering`, `create_inventory`, and `create_lifecycles` scenarios from the mockstack tests. Those scenarios still exist under `tests/`.
