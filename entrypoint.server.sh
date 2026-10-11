#!/bin/bash
set -e

echo "--> Configuring OPA server agent (sftd)..."

mkdir -p /etc/sft
mkdir -p /var/lib/sftd

# Use an existing enrollment token file, otherwise fall back to the environment variable
if [ -f /var/lib/sftd/enrollment.token ]; then
    echo "--> Existing enrollment token found. Using it."
elif [ -n "${SFT_ENROLLMENT_TOKEN}" ]; then
    echo "${SFT_ENROLLMENT_TOKEN}" > /var/lib/sftd/enrollment.token
    echo "--> Enrollment token written from SFT_ENROLLMENT_TOKEN."
else
    echo ""
    echo "  ╔══════════════════════════════════════════════════════════════╗"
    echo "  ║  WARNING: /var/lib/sftd/enrollment.token does not exist      ║"
    echo "  ║           and SFT_ENROLLMENT_TOKEN is not set               ║"
    echo "  ║                                                              ║"
    echo "  ║  The server agent will start but cannot enroll into OPA.     ║"
    echo "  ║                                                              ║"
    echo "  ║  1. Create a 'Server' enrollment token in the OPA Console:   ║"
    echo "  ║     Resource Administration > Servers > Enrollment Tokens    ║"
    echo "  ║  2. Set SFT_ENROLLMENT_TOKEN=<token>                         ║"
    echo "  ║     or mount a /var/lib/sftd/enrollment.token file.          ║"
    echo "  ║  3. Restart the server agent container.                      ║"
    echo "  ╚══════════════════════════════════════════════════════════════╝"
    echo ""
fi

echo "--> Starting syslog (forwarding to Docker stdout)..."
rsyslogd

echo "--> Starting OPA server agent daemon (sftd)..."
exec /usr/sbin/sftd --syslog
