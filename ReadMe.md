# Self Hosted Integration Runtime for Azure Data Factory

### What is SHIR?

A self-hosted integration runtime (SHIR) is a secure connection between on-premises resources and the cloud. It is an instance of the Azure Integration Runtime (IR) that is installed and managed on-premises.

### A SHIR can:

- Run copy activities between a cloud data store and a data store in a private network
- Dispatch transform activities against compute resources in an on-premises network or an Azure virtual network
- Scan data sources in an on-premises network or a virtual network

A SHIR can access resources in both public and private networks. It uses Windows DPAPI to encrypt sensitive data and credential information.

### How to create SHIR?

- Create a data factory
- Create a self-hosted integration runtime
- Select Integration runtimes on the left pane
- Select +New
- On the Integration runtime setup page, select Azure, Self-Hosted, and then select Continue
- On the following page, select Azure to create an Azure IR, and then select Continue
- Enter a name for your Azure IR, and select Create
- Select the use system proxy option in the SHIR application HTTP Proxy settings
- Open the relevant config files in an Administrator session of Notepad
- Update the code so that traffic intended for your ADF resource bypasses the proxy
- Create a VM
- Download and install integration runtime
- Execute the installed integration runtime
- From ADF extract primary/secondary key for SHIR
- Paste the key
- If all goes well, your connection is now setup

### Challenges creating SHIR
