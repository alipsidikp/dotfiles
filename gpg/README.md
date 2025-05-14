# GPG Configuration

Place your GPG keys and configuration files in this directory.

## Required Files

- `gpg-key.asc` - Your exported GPG key for importing
- (Optional) Additional GPG configuration files

## Usage

The setup script will automatically:
1. Install GPG and pinentry-mac
2. Import your GPG key from gpg-key.asc if present
3. Configure Git to use GPG for signing commits

## Manual GPG Key Creation

If you don't have a GPG key yet, you can create one by running:

```bash
gpg --full-generate-key
```

Then export it with:

```bash
gpg --export-secret-keys --armor YOUR_KEY_ID > gpg-key.asc
```

Replace `YOUR_KEY_ID` with your actual GPG key ID. 