# Terraform

## Listing

Initialized workspaces.

```shell
list_workspaces () {
dir="${1:-PWD}"
find "$dir" -type d -name '.terraform' | sed -e 's|/.terraform||'
}
```

## Inventory

Given a terraform workspace, assuming git:

```shell
print_inventory () {
  terraform show -json | jq -rc '.. | .resources? | select(.) | .[] | select(.type) | [
    .type,
    .values.id,
  ] | @tsv'
}
```

The resulting line-oriented format is easy to query for resources of a specific type. This becomes more useful the more state files are included.

```shell
list_workspaces infra |
while read dir
do (cd "$dir"; print_inventory)
done
```

A more useful variety could leverage knowledge of the source, and target platform.

```shell
print_inventory () {
  export INVENTORY_REPO="$(git remote get-url origin)"
  export INVENTORY_PATH="$(git rev-parse --show-prefix)"
  terraform show -json |
  jq -rc '.. | .resources? | select(.) | .[] |
    select(.type) |
    select(.type | startswith("google_")) |  # only gcp
    select(.type | contains("_iam") | not) | # not iam
    [ .type,
      .values.id,
      env.INVENTORY_REPO,
      env.INVENTORY_PATH
    ] | @tsv
  '
}
```

With this a resource like a bucket could be quickly along with the repo and directory where it was created.
