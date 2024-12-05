# utils.sh
#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}=== $1 ===${NC}"
}

print_error() {
    echo -e "${RED}=== $1 ===${NC}"
}

check_command() {
    command -v "$1" >/dev/null 2>&1
}
