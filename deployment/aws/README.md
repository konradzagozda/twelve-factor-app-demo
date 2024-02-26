# AWS Setup

## Dependencies

## Commands

Create cluster:

```sh
ansible-playbook 1.setup.ansible.yaml --extra-vars "aws_profile=your_profile_name aws_region=us-west-2"
```

Deploy app:

```sh
ansible-playbook 2.deploy.ansible.yaml --extra-vars "aws_profile=your_profile_name aws_region=us-west-2"
```
