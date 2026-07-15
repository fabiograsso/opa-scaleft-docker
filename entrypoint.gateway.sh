#!/bin/bash
set -e

echo "--> Configuring OPA Gateway for database integration..."

mkdir -p /etc/sft
mkdir -p /var/lib/sft-gatewayd

# Use an existing setup token file, otherwise fall back to the environment variable
if [ -f /var/lib/sft-gatewayd/setup.token ]; then
    echo "--> Existing setup token found. Using it."
elif [ -n "${SFT_SETUP_TOKEN}" ]; then
    echo "${SFT_SETUP_TOKEN}" > /var/lib/sft-gatewayd/setup.token
    echo "--> Setup token written from SFT_SETUP_TOKEN."
else
    echo ""
    echo "  ╔══════════════════════════════════════════════════════════════╗"
    echo "  ║  WARNING: /var/lib/sft-gatewayd/setup.token does not exist   ║"
    echo "  ║           and SFT_SETUP_TOKEN is not set in .env             ║"
    echo "  ║                                                              ║"
    echo "  ║  The gateway will start but cannot enroll into OPA.          ║"
    echo "  ║                                                              ║"
    echo "  ║  1. Create an 'Infrastructure orchestrator' setup token in   ║"
    echo "  ║     OPA Console: Resource Administration > Gateways          ║"
    echo "  ║  2. Add SFT_SETUP_TOKEN=<token> to your .env file            ║"
    echo "  ║     or create a /var/lib/sft-gatewayd/setup.token file.      ║"
    echo "  ║  3. Restart the gateway container.                           ║"
    echo "  ╚══════════════════════════════════════════════════════════════╝"
    echo ""
fi

echo "--> Starting OPA Gateway daemon..."
exec /usr/sbin/sft-gatewayd service
