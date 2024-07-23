#  Health Check Script on a Remote Linux System
This script performs a basic health check on a remote Linux system through SSH. It retrieves and displays system information, CPU usage, memory usage, top 5 CPU and memory-consuming processes, and disk usage. It also provides a summary of resource status, highlighting any potential issues.
System Information: Hostname, FQDN, IPv4 Address, Operating System, Distribution, Kernel Version, Uptime.

See detailed information under the "Sample Output" file.

## How to use it:

<b>1. Clone the repository:</b><br>
git clone '"repository-url"<br>
cd "repository-directory"<br>

or<br>
<b>Create a new script with a text editor (nano/vi) and copy the content into it.</b>

<b>2. Make the script executable:</b><br>
chmod +x health_check.sh

<b>3. Run the script:<br></b>
./health_check.sh<br>
Enter the hostname of the server to inspect when prompted. Ensure you have SSH access to the remote server.
