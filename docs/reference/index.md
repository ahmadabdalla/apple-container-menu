# Reference

Verified external facts the decisions rely on.

* [container ls JSON output](cli-json-output.md) - the ls --all --format json command and the fields the app decodes.
* [container status.state values](container-state-values.md) - status.state is binary (running or stopped); no transient lifecycle states.
* [container service status behavior](service-status.md) - exit-code and message behavior when the service is down.
* [container binary locations](binary-paths.md) - where the binary lives by install method and why PATH is unreliable.
* [SwiftUI MenuBarExtra API](swiftui-menubarextra.md) - MenuBarExtra and the .menu style are available on macOS 13 and later.
* [NSStatusItem menu open trigger](nsstatusitem-menu-open.md) - NSMenu menuWillOpen is the reliable open hook; MenuBarExtra .menu has none.
* [Disabled NSMenuItem images](disabled-menu-item-images.md) - disabled menu rows can still show non-template palette SF Symbol images clearly.
