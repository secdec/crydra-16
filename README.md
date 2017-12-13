# Crydra-16 Overview
The goal of this tool is to simplify the automated testing of password attacks using existing tools. The Hydra tool (https://github.com/vanhauser-thc/thc-hydra) is extremely powerful, and can brute force passwords based on dictionary files (i.e. CAPEC-16)or based on allowed character sets (i.e. CAPEC-49).

The Hydra tool is based primarily on text-based output to standard out. In order to provide more flexible automation options, we augmented the Hydra tool by adding a command line option to output in structured JSON format, which allows
the output to be more easily interpreted by automated tools. This modification has already been accepted into Hydra's v8.5 mainstream release (https://github.com/vanhauser-thc/thc-hydra/blob/v8.5/CHANGES).

With this change, Cydra-16 became a convenience wrapper around the mainstream Hydra tool. The purpose of the wrapper is to follow the same paradigm as other Attack Orchestration Scripts so that CQF can treat attack tools uniformly. Namely, the wrapper script takes input in a configuration file and places the JSON output from Hydra in the specified file.

# Execution
At a high level, the execution can be summarized as: `crydra-16 [-v] [input-attack.conf] [output-file]`

The following configuration parameters encapsulate the primary information necessary to execute a password-based attack against a web application:
* **username**: the username to brute force
* **host**: the hostname for the application
* **port**: the port running the application
* **useTLS**: whether or not the application uses HTTPS
* **uripath**: the URL of the login page
* **formdata**: the HTTP POST data for login
* **msgsuccess**: a message on the HTTP Response that can be used to determine
the login was successful (should *not* be specified if **msgfailure** is provided)
* **msgfailure**: a message on the HTTP Response that can be used to determine
the login failed (should *not* be specified if **msgsuccess** is provided)
* **dictionaryfile**: the file containing the dictionary of passwords to use
* **threads**: how many threads to utilize in the brute force attempt

These configuration parameters are placed in a text file (see `samples/sample-attack.conf`)
as name/value pairs in a property file. For example:

```bash
username='user@example.com'
```

Using these configuration parameters, our wrapper script (`crydra-16`) simply invokes Hydra with the appropriate flags to pass in the above configuration parameters.

Hydra then generates JSON similar to the following:
```javascript
{
  "generator": {
    "software": "Hydra",
    "version": "v8.6-dev",
    "built": "2017-06-23 06:46:12",
    "server": "target.example.com",
    "service": "http-post-form",
    "jsonoutputversion": "1.00",
    "commandline": "/usr/local/bin/hydra -I -V -o /tmp/crydra-tmp-28618-results.json -b jsonv1 -s 8080 -L /tmp/crydra-tmp-28618-userlist.txt -t 2 -W 0 -d -P dictionary_sample_12.txt target.example.com http-post-form /c/portal_public/login:my_account_cmd=auth&referer=%2Fc&my_account_r_m=false&password=^PASS^&my_account_login=^USER^&my_account_email_address=:S=Processing login..."
  },
  "results": [
    {
      "port": 8080,
      "service": "http-post-form",
      "host": "target.example.com",
      "login": "bill@dotcms.com",
      "password": "bill"
    }
  ],
  "success": true,
  "errormessages": [],
  "quantityfound": 1
}
```

# Installation
The Quick Demo below uses the included `Vagrantfile` to setup a virtual machine with all the necessary components to use the `crydra-16` wrapper script as described above. However, the included `install.sh` shell script can also be used to install
the necessary components on an Ubuntu 16.04.2 64-bit system.

The `install.sh` script installs gcc, copies over `crydra-16`, and downloads and compiles known versions of Hydra.

# Quick Demo
As a demonstration, a Vagrantfile has been provided that installs the Crydra-16 components and a sample target application (an old vulnerable version of dotCMS).

## Prerequisites
In order to execute the quick demo below, Vagrant and VirtualBox must be installed. Installers for these products are available from HashiCorp and Oracle respectively:
* Vagrant (https://www.vagrantup.com/downloads.html)
* VirtualBox (https://www.virtualbox.org/wiki/Downloads)
* An SSH client
 * On Windows, you will also need an SSH client such as PuTTY:
  * Install PuTTY (http://www.chiark.greenend.org.uk/~sgtatham/putty/)
  * Ensure putty.exe and puttygen.exe are on your PATH
  * Assuming Vagrant has already been installed, from a Powershell or cmd type:
    `vagrant plugin install vagrant-multi-putty`

## Instructions
Use the following steps to manually execute an attack scenario for the Crydra-16 tool:
1. `vagrant up`
2. `vagrant ssh` (or `vagrant putty` on Windows)
4. `crydra-16 -v /opt/attack-scripts/crydra16/samples/sample-attack.conf ~/output.json`
5. `cat ~/output.json`
