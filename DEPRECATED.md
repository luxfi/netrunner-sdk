# DEPRECATED

`luxfi/netrunner-sdk` is deprecated. It was a fork of the gRPC client in
`luxfi/netrunner` that drifted out of sync and has no remaining consumers.

Use `github.com/luxfi/netrunner/client` directly (the canonical client that
ships with the netrunner server).

The protobuf wire format used here was vestigial — Lux's canonical wire
protocol is **ZAP** (Zero-Copy App Proto, see `github.com/luxfi/api/zap`).
