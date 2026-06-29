# OTA Package

This directory contains the payload used to build a Kindle OTA package.

The intended flow is:

1. Stage `kindle-ota-blocker/` into `payload/`.
2. Package this directory with `kindletool create ota2 ...`.
3. Install the resulting `.bin` via `Update Your Kindle`.

The actual `.bin` is not checked in here.
