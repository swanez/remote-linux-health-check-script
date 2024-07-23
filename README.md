##  Health Check Script on a Remote Linux System
This script performs a basic health check on a remote Linux system through SSH. It retrieves and displays system information, CPU usage, memory usage, top 5 CPU and memory-consuming processes, and disk usage. It also provides a summary of resource status, highlighting any potential issues.
System Information: Hostname, FQDN, IPv4 Address, Operating System, Distribution, Kernel Version, Uptime.

See detailed information under the "Sample Output" file.

### How to use it:
1. <b>Create a new file (health_check.sh) with a text editor (nano/vi) and copy the content into it.</b>

2. <b>Make the script executable:</b><br>
chmod +x health_check.sh

3. <b>Run the script:<br></b>
./file_name<br>
Enter the hostname of the server to inspect when prompted. Ensure you have SSH access to the remote server.
