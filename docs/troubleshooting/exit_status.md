# Exit Status

Common exit status codes. If related to a specific app then the code is labeled as such.

## 60

:octicons-apps-16: berglas

The exit status when [berglas](https://github.com/GoogleCloudPlatform/berglas) cannot read a secret. Check your [berglas refs](https://github.com/GoogleCloudPlatform/berglas/blob/main/doc/reference-syntax.md), the identity you're using, and that the identity has read access to the secret.

Sightings:

- `Pod errors: Error with exit code 60`

## 128

Typically means the command does not exist or is not executable. Make sure the command exists and is executable (`chmod +x`).

Sightings:

- `Pod errors: StartError with exit code 128`

## 130

Indicates a command received an interrupt. Not an issue, just what happened.

## 141

Indicates a command was not able to write to a pipe. Not an issue, just what happened.
