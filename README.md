# docker-saltstack

Docker Compose setup to spin up a Salt master and minions with the latest SaltProject version.

## Current Version

This project now uses **Salt 3007.11** (latest stable release as of January 2026), installed via PyPI in a Python virtual environment. This approach provides:
- Modern "onedir-style" packaging with isolated dependencies
- Latest security updates and features
- Ubuntu 24.04 LTS base image
- Easy version management and upgrades

## Quick Start

You can read a full article describing how to use this setup [here](https://medium.com/@timlwhite/the-simplest-way-to-learn-saltstack-cd9f5edbc967).

You will need a system with Docker and Docker Compose installed to use this project.

Just run:

`docker compose up`

from a checkout of this directory, and the master and minion will start up with debug logging to the console.

Then you can run (in a separate shell window):

`docker compose exec salt-master bash`

and it will log you into the command line of the salt-master server.

From that command line you can run something like:

`salt '*' test.ping`

and in the window where you started docker compose, you will see the log output of both the master sending the command and the minion receiving the command and replying.

[The Salt Remote Execution Tutorial](https://docs.saltproject.io/en/latest/topics/tutorials/modules.html) has some quick examples of the commands you can run from the master.

Note: you will see log messages like : "Could not determine init system from command line" - those are just because salt is running in the foreground and not from an auto-startup.

The salt-master is set up to accept all minions that try to connect.  Since the network that the salt-master sees is only the docker-compose network, this means that only minions within this docker-compose service network will be able to connect (and not random other minions external to docker).

#### Running multiple minions:

`docker compose up --scale salt-minion=2`

This will start up two minions instead of just one.

#### Host Names
The **hostnames** match the names of the containers - so the master is `salt-master` and the minion is `salt-minion`.

If you are running more than one minion with `--scale=2`, you will need to use `docker-saltstack_salt-minion_1` and `docker-saltstack_salt-minion_2` for the minions if you want to target them individually.

## What's New

### 2026 Update

- **Upgraded to Salt 3007.11** - Latest stable version with all recent security patches and features
- **Ubuntu 24.04 LTS** - Modern, long-term supported base OS
- **Modern packaging** - Uses Python virtual environment with PyPI installation for better isolation
- **Improved Dockerfiles** - Cleaner, more maintainable configuration
- **Salt API Enabled** - REST API exposed on port 8000 for external automation and integration

### Migration from Old Version

The old setup used Ubuntu 18.04 and Salt installed from the deprecated `repo.saltstack.com` repository. The new version:
- Uses official PyPI packages
- Provides better security and maintainability  
- Maintains backward compatibility with existing Salt states and configurations
- Adds Salt API for programmatic access

## Salt API Usage

The Salt Master now includes the Salt API (rest_cherrypy) exposed on port 8000. This allows you to control Salt programmatically from external applications.

### Quick API Examples

**1. Login and get a token:**
```bash
curl -sSk http://localhost:8000/login \
  -H "Accept: application/json" \
  -d username=salt \
  -d password=changeme_insecure_default \
  -d eauth=sharedsecret
```

**2. Execute commands using the token:**
```bash
# Replace YOUR_TOKEN with the token from login response
curl -sSk http://localhost:8000 \
  -H "Accept: application/json" \
  -H "X-Auth-Token: YOUR_TOKEN" \
  -d client=local \
  -d tgt='*' \
  -d fun=test.ping
```

**3. Get minion status:**
```bash
curl -sSk http://localhost:8000 \
  -H "Accept: application/json" \
  -H "X-Auth-Token: YOUR_TOKEN" \
  -d client=local \
  -d tgt='*' \
  -d fun=status.uptime
```

### Security Configuration

**⚠️ IMPORTANT FOR PRODUCTION:**

The default configuration uses:
- HTTP (not HTTPS) - `disable_ssl: True`
- Shared secret authentication with default password `changeme_insecure_default`

**For production environments, you should:**

1. **Enable SSL/TLS:**
   - Generate SSL certificates
   - Update `/etc/salt/master` to use `ssl_crt` and `ssl_key`
   - Remove `disable_ssl: True`

2. **Use secure authentication:**
   - Change the shared secret by setting `SALT_SHARED_SECRET` environment variable
   - Or switch to PAM authentication for user-based access control
   - Configure granular permissions in `external_auth`

3. **Example with custom secret:**
```bash
SALT_SHARED_SECRET=your_secure_secret_here docker compose up
```

### API Documentation

For full API documentation, see:
- [Salt API Documentation](https://docs.saltproject.io/en/latest/ref/netapi/all/salt.netapi.rest_cherrypy.html)
- [External Authentication](https://docs.saltproject.io/en/latest/topics/eauth/index.html)

### API Test Scripts

Two test scripts are provided to help you get started:

1. **Bash Script (`test-api.sh`)** - Simple curl-based examples
   ```bash
   ./test-api.sh
   ```

2. **Python Script (`test-api.py`)** - Python client example with reusable class
   ```bash
   pip install requests  # Install requests library first
   ./test-api.py
   ```

These scripts demonstrate:
- Authentication and token management
- Basic minion commands
- Gathering system information
- Executing shell commands via Salt
