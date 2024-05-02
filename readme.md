Create an AKS Cluster in Azure with Terraform



wget https://raw.githubusercontent.com/ACloudGuru-Resources/advanced-terraform-with-azure/main/lab_aks_cluster/lab_7_setup.sh


https://learn.acloud.guru/handson/4b03a9a4-9a91-4c5d-bf58-f0049af5aaff

Introduction
In this lab, using the Azure portal, you will configure the Cloud Shell and download and run the lab setup script. Next, you will import the resource group. Then, you will add your AKS, variable, and outputs to the configuration. Lastly, you will deploy your Kubernetes cluster resources and verify that the cluster is up and healthy.

Solution
Log in to the Azure portal using the credentials provided on the lab instructions page. Be sure to use an incognito or private browser window to ensure you’re using the lab account rather than your own.

Note: This lab uses the Vim text editor. When copying and pasting code into Vim from the lab guide, first enter :set paste (and then i to enter insert mode) to avoid adding unnecessary spaces and hashes. To save and quit the file, press Escape followed by :wq. To exit the file without saving, press Escape followed by :q!.

Set Up the Cloud Shell and Lab Environment
In the Azure portal, click on the Cloud Shell icon (>_) at the top of the page, to the right of the search bar.

Select Bash.

Click Show advanced settings.

For the Cloud Shell region, select the same region as your resource group location (This will be noted above, in the portal).

For Storage account, choose Use existing.

Under File share, select Create new and type in the name of terraform.

Click Create storage. Your Cloud Shell should begin to configure.

Run the following command to pull down the lab setup script from the GitHub repo:

wget https://raw.githubusercontent.com/ACloudGuru-Resources/advanced-terraform-with-azure/main/lab_aks_cluster/lab_7_setup.sh

Runls to list the contents.

You should see the lab setup script listed, lab_7_setup.sh.

Run chmod +x lab_7_setup.sh to make it executable. .

Run the script, ./lab_7_setup.sh.

Run ls to list the contents.

You should see a terraformguru directory listed.

Run cd terraformguru/ to change into that directory.

List the contents by running ls.

You should see one configuration file listed: providers.tf.

Run vim providers.tf to take a look at the file.

Type Esc :q to quit out of the file.

Import the Resource Group
Run terraform init to initialize the working directory.

Run az group list to look up the subscription ID.

Copy the subscription ID to your clipboard. It should be located on the top line after "id":. Make sure to copy all of the characters in between the quotation marks.

Run the following command, making sure to paste in your copied subscription ID to replace <SUBSCRIPTION_ID>:

terraform import azurerm_resource_group.k8s <SUBSCRIPTION_ID>
Note: It may take a minute to import your resource.

Run vim providers.tf to edit the file.

Note: When copying and pasting code into Vim from the lab guide, first enter :set paste (and then i to enter insert mode) to avoid adding unnecessary spaces and hashes. To save and quit the file, press Escape followed by :wq. To exit the file without saving, press Escape followed by :q!.

Delete the comment hashes (#) in front of name and location.

Replace the placeholder <RESOURCE_GROUP_NAME> next to name.

Copy the resource group name located at the top left of the Azure portal, under Home.
Paste it into the file, to replace <RESOURCE_GROUP_NAME> making sure not to replace the quotation marks.
Replace the placeholder <RESOURCE_GROUP_LOCATION> next to location.

Copy the resource group location listed to the right of Location in the Azure portal. (If you hover over it, a copy icon should appear that you can click to copy it to your clipboard.)
Paste it into the file, to replace <RESOURCE_GROUP_LOCATION> making sure not to replace the quotation marks.
Type Esc followed by :wq to save and quit the file.

Run the following command to create an SSH key:

ssh-keygen -m PEM -t rsa -b 4096
Hit Enter to keep the defaults.

Hit Enter to leave the passphrase empty.

Hit Enter again to create your key pair.

Add the AKS Config, Variables, and Outputs to the Configuration
Run vim aks.tf to create your first configuration file.

Enter the following configuration:

resource "azurerm_kubernetes_cluster" "k8s" {
    name                = var.cluster_name
    location            = azurerm_resource_group.k8s.location
    resource_group_name = azurerm_resource_group.k8s.name
    dns_prefix          = var.dns_prefix

    linux_profile {
        admin_username = "ubuntu"
        ssh_key {
            key_data = file(var.ssh_public_key)
        }
    }

    default_node_pool {
        name            = "agentpool"
        node_count      = var.agent_count
        vm_size         = "Standard_D2s_v3"
        os_disk_size_gb = 30
    }

    service_principal {
        client_id     = var.aks_service_principal_app_id
        client_secret = var.aks_service_principal_client_secret
    }

    network_profile {
        load_balancer_sku = "standard"
        network_plugin = "kubenet"
    }

    tags = {
        Environment = "Development"
    }
}
Type Esc followed by :wq to save and quit the file.

Run vim variables.tf to create your next configuration file.

Enter the following configuration. Be sure to replace <YOUR_RESOURCE_GROUP_LOCATION> with the location of your resource group, and replace <SERVICE_PRINCIPAL_APP_ID> and <SERVICE_PRINCIPAL_CLIENT_SECRET> with the service principal IDs generated for this lab, which can be found in the lab credentials section.

variable "resource_group_location" {
    default = "<YOUR_RESOURCE_GROUP_LOCATION>"
}

variable "agent_count" {
    default = 3
}

variable "ssh_public_key" {
    default = "~/.ssh/id_rsa.pub"
}

variable "dns_prefix" {
    default = "k8sguru"
}

variable cluster_name {
      default = "k8sguru"
}

variable aks_service_principal_app_id {
    default = "<SERVICE_PRINCIPAL_APP_ID>"
}

variable aks_service_principal_client_secret {
    default = "<SERVICE_PRINCIPAL_CLIENT_SECRET>"
}
Type Esc followed by :wq to save and quit the file.

Run vim output.tf to create your final configuration file.

Enter the following configuration:

output "resource_group_name" {
    value = azurerm_resource_group.k8s.name
}

output "client_key" {
    value = nonsensitive(azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)
}

output "client_certificate" {
    value = nonsensitive(azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)
}

output "cluster_ca_certificate" {
    value = nonsensitive(azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)
}

output "cluster_username" {
    value = nonsensitive(azurerm_kubernetes_cluster.k8s.kube_config.0.username)
}

output "cluster_password" {
    value = nonsensitive(azurerm_kubernetes_cluster.k8s.kube_config.0.password)
}

output "kube_config" {
    value = azurerm_kubernetes_cluster.k8s.kube_config_raw
    sensitive = true
}

output "host" {
    value = nonsensitive(azurerm_kubernetes_cluster.k8s.kube_config.0.host)
}
Type Esc followed by :wq to save and quit the file.

Deploy and Verify the Kubernetes Cluster is Running
Run terraform fmt to check the formatting of your configuration files.

Your aks.tf, output.tf, providers.tf, and variables.tf files should be listed.

Run terraform validate to validate the code in your configuration files.

You should see a message confirming that your configuration is valid.

Run terraform plan -out aks.tfplan to create your execution plan.

Run terraform apply aks.tfplan to execute your execution plan.

Note: It may take a couple of minutes to deploy your resources.

You will see a big block of text appear, which should mean that your cluster deployed successfully. You can scroll up to view the Apply complete message in green to confirm.

Scrolling down from the Apply complete message, you can view the client_certificate, client_key, cluster_ca_certificate, cluster_password, and cluster_username. Lastly, you should see the host address, kube_config, and resource_group_name.

Run the following command to move your kube_config to a different file:

echo "$(terraform output kube_config)" > ./azurek8s
Run cat ./azurek8s to check the file.

You should see EOT at the beginning and end of the file, which will need to be removed.

Run vim ./azurek8s to edit the file.

Delete the <<EOT at the beginning and the EOT at the end of the file.

Type Esc followed by :wq to save and quit the file.

Run export KUBECONFIG=./azurek8s to create your environment variable.

Run kubectl get nodes to check if your nodes are running and healthy.

You should see your 3 nodes returned with a STATUS of Ready.

Conclusion
Congratulations — you've completed this hands-on lab!