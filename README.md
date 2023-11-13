# webMethods Suite Logfile Archiver
Archive and (after a customizable retention period) delete log files from webMethods Suite products

- Main logic implemented as Ant script for portability
  - Invocation directly or via convenience scripts (Windows batch file and shell script)
  - Support for
    - Integration Server and Microservices Runtime
    - Universal Messaging
    - MWS
    - Optimize
      - Analytic Engine
      - Web Service Data Collector
    - Command Central
      - CCE
      - SPM
    - Other components can be added via configuration


## Prerequisites

- Install [Apache Ant](https://ant.apache.org) version 1.7 or higher, including [ant-contrib](http://ant-contrib.sourceforge.net/)
- Configure the following environment variables
  - `ANT_HOME` pointing to your Ant installation location
  - `WEBMETHODS_HOME` pointing to the location directory of the webMethods suite
  - `JAVA_HOME` pointing to a JDK. The easiest way will be to leverage the value from `WEBMETHODS_HOME`.
    - Linux/UNIX/macOS:  `JAVA_HOME=$WEBMETHODS_HOME/jvm/jvm` (enclose in double-quotes, if the path contains spaces)
    - Windows: `JAVA_HOME=%WEBMETHODS_HOME%\jvm\jvm`
- Ensure that `$ANT_HOME/bin` and `$JAVA_HOME/bin` are part of the search path (`PATH` variable)

## Installation

- Option 1: Build ZIP file (will be placed into `./dist`) for manual installation by simply calling Ant with the default target: `ant`
- Option 2: Install on current system 
  - Default location (`$WEBMETHODS_HOME/tools/operations`): `ant install`
  - Custom installation directory: `ant -Dinstall.dir=<CUSTOM_INSTALL_DIR> install` 

## Usage

The script files' (`run_log-archive.bat` and `run_log-archive.sh`) logic is such that on a normal system no further setup work is required. But on systems where a more elaborate configuration exists, those specifics are taken into account. Therefore the following environment variables are used (if they are all defined, the archiver files can be stored anywhere):

- `WEBMETHODS_HOME`: Installation location of the webMethods Suite for which the log files should be archived. If not defined, it will be assumed that the script is installed in `$WEBMETHODS_HOME/tools/operations/logArchiver` and the value derived from that.
- `JAVA_HOME`: 
  - On Linux only and if it is not set, the script uses the contents of `/etc/profile.d/jdk.sh` if it exists. 
  - If not defined, the JVM that comes with the webMethods Suite will be used (depends on name of JVM folder and may therefore not work on all versions of the webMethods Suite).
- `ANT_HOME`:
  - On Linux only and if it is not set, the script uses the contents of `/etc/profile.d/ant.sh` if it exists.
  - If not defined, the Ant that comes as part of the Asset Build Environment will be used.

It is recommended for most cases to set up a scheduled job (e.g. via Cron) on the operating system to execute the script on a daily basis. Please be aware that in this case the environment variables may differ from what is normally available when a user is logged in.

It is also an option to run the Ant script from a Continuous Integration server (like e.g. Jenkins). In that case the control over environment variables may be easier than via a Cron job.

On Windows systems there have been cases where, due to file locks, log files could only be moved one or several days after that should have happened. While this delay may be a bit annoying, it is usually not a real problem.
  

## Parameters

The behavior is controlled by Ant properties with defaults being in the script. Those defaults can be overridden from the command line by using standard Ant syntax.

Example:

````
ant -f build_log-archive.xml -DretentionDays=12
````

The following parameters can be used

| Name | Default | Format | Description | Min. Version |
| ---  | ---     | ---    | ---         | ---          |
| `webMethods.home` | OS environment variable `$WEBMETHODS_HOME` | Valid path | Location of the webMethods installation | 1.0 |
| `createZIP` | true | true/false | Should a ZIP be created per invocation | 1.1 |
| `retentionDays` | 30 | positive number | Number after which log files (not ZIP) shall be deleted | 1.0 |
| `retentionDaysZIP` | 60 | positive number | Number after which ZIP archives shall be deleted | 1.1 |
| `instancesNameIS` | default | text | Name of IS instance for which files shall be archived | 1.1 |
| `instanceNameUM` | umserver | text | Name of UM server instance for which file shall be archived | 1.2 |

______________________
These tools are provided as-is and without warranty or support. They do not constitute part of the Software AG product suite. Users are free to use, fork and modify them, subject to the license agreement. While Software AG welcomes contributions, we cannot guarantee to include every contribution in the master project.

Contact us at [TECHcommunity](mailto:technologycommunity@softwareag.com?subject=Github/SoftwareAG) if you have any questions.
