# Network Scanner with VLSM support (Variable Length Subnet Masking) in Bash

## Overview

This Bash script serves as a network scanner for local networks, utilizing Variable Length Subnet Masking (VLSM). It requires Bash and the ASCII art file `ascii_art.txt` to operate.

## Features

- **VLSM Support**: The script supports scanning networks with Variable Length Subnet Masking, allowing for flexible subnet configurations.
- **ASCII Art**: Enhance your user experience with the included ASCII art from `ascii_art.txt`.
- **Easy to Use**: Execute the script with Bash, providing necessary permissions, and follow the prompts.

## Prerequisites

Ensure the following are available before running the script:

- Bash (Bourne Again SHell)

## Usage

1. Clone the repository:

    ```bash
    git clone https://github.com/Hamibubu/HamiBashNetscanner.git
    ```

2. Navigate to the script directory:

    ```bash
    cd HamiBashNetscanner
    ```

3. Make the script executable:

    ```bash
    chmod +x hostDiscovery.sh
    ```

4. Run the script:

    ```bash
    ./hostDiscovery.sh -i 192.168.100.0/24
    ```

## License

This project is licensed under the [GNU General Public License v3.0](LICENSE)