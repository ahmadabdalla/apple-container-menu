---
type: Reference
title: Disabled NSMenuItem images
description: Disabled NSMenuItem rows can still show non-template palette SF Symbol images clearly when verified in the app.
timestamp: 2026-06-22
tags: [appkit, menu, image, accessibility]
resource: https://developer.apple.com/documentation/appkit/nsmenuitem/image
---

# Disabled NSMenuItem images

`NSMenuItem.image` supports an image displayed beside the item title. In this
app, disabled informational rows remain read-only while still carrying a
non-template SF Symbol image configured with palette colours.

Visual verification on 2026-06-22 confirmed that filled green and filled red
`circle.fill` images on disabled populated rows remained readable in both light
and dark appearance.

## Citations

[1] [NSMenuItem image](https://developer.apple.com/documentation/appkit/nsmenuitem/image)
[2] Verified by visual app test, 2026-06-22, issue #25 implementation branch.
