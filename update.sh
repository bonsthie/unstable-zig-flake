#!/usr/bin/env bash

set -e  # Exit on error

export JSON_SHA256=$(nix-prefetch-url "https://ziglang.org/download/index.json")

nix-build compute-hash.nix
FILE="result"
echo "$FILE"
rm "zig-lock.json"
cp "$FILE" "zig-lock.json"

nix build
