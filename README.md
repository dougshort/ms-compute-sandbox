# CBTS Managed Services

CBTS Managed Services Linux Run Team Playbooks

### Prerequisites

Prior to running these playbooks, some minor manual tweaks are required

    - Edit 'hosts' in your Ansible root directory to reflect new servers

    - Run 'ansible-playbook prepare_ansible_<OS-Type>_target.yml -k --ask-sudo-pass -i hosts'

### Installing Provisioning Playbooks

It's imperative that the inventory file is correct for your environment. 

    - Make sure to place 'ansible.cfg' in your root playbook directory
        ex. /home/cbtsadmin/ms-compute/ansible.cfg

    - The ansible.cfg in your root overrides settings in /etc/ansible/ansible.cfg

### Deployment

Deploy from your ansible root as such:
    ex. ansible-playbook site.yml

#### Contributors

    * Doug Short - douglas.short@cbts.net

