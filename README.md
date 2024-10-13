# Jenkins Deployment on Kubernetes

This project provides a script and configuration files to deploy Jenkins on a Kubernetes cluster. It utilizes `kubectl` for Kubernetes interactions and `kind` to create a local Kubernetes cluster if one does not exist.

## Prerequisites

Before running the deployment script, ensure that the following tools are installed on your system:

1. **kubectl**: This command-line tool is necessary to manage Kubernetes clusters. You can install it following the instructions in the [official documentation](https://kubernetes.io/docs/tasks/tools/install-kubectl/).
   
2. **kind**: This tool allows you to run Kubernetes clusters in Docker containers. Follow the instructions in the [official documentation](https://kind.sigs.k8s.io/docs/user/quick-start/) to install it.

## Project Files

- **install-jenkins.sh**: A bash script that checks for an existing Kubernetes cluster and installs Jenkins. It creates a Kind cluster if none exists.
  
- **jenkins.deployment.yml**: Kubernetes deployment configuration for Jenkins, defining the deployment and service necessary for Jenkins to run.

- **jenkins.pv.kind.template**: Template for creating a Persistent Volume (PV) for Kind clusters.

- **jenkins.pv.linux.template**: Template for creating a Persistent Volume (PV) for Linux-based clusters.

- **local-storage-class.yml**: Defines a StorageClass for local persistent storage in Kubernetes.

- **jenkins-data/config.xml**: Configures Jenkins with default settings, including user security and job execution settings.

## Quick Start

Follow these steps to set up Jenkins on Kubernetes:

1. Clone this repository to your local machine (if applicable):

   ```bash
   git clone git@github.com:magicalbob/k8s_jenkins.git
   cd k8s_jenkins
   ```

2. Make the installation script executable:

   ```bash
   chmod +x install-jenkins.sh
   ```

3. Run the installation script:

   ```bash
   ./install-jenkins.sh
   ```

4. After running the script, Jenkins will be accessible on your local machine at `http://localhost:40080`. You can access the Jenkins UI in your browser.

## Usage

- You can configure Jenkins through the web UI once it is up and running.
- The Jenkins data, including jobs and configurations, will be stored in a persistent volume, ensuring that your setups are retained across restarts.

## Troubleshooting

- If you encounter issues with Kubernetes connectivity, ensure that your `kubectl` is configured properly using the `kubectl config view` command.
- Check logs for the Jenkins pod by running:

  ```bash
  kubectl logs -n jenkins <jenkins-pod-name>
  ```

## Additional Information

- For more details on how to install and configure Jenkins, check out the [official Jenkins documentation](https://www.jenkins.io/doc/).
- To learn more about Kubernetes and Kind, refer to the respective documentation [Kubernetes](https://kubernetes.io/docs/home/) and [Kind](https://kind.sigs.k8s.io/).

## License

This project is licensed under the [MIT License](LICENSE).

## Contributing

Feel free to open issues or submit pull requests if you have suggestions for improvements or enhancements.
