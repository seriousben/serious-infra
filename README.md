# serious-infra

Serious infrastructure for serious projects.


### Applying

Continuous integration is done using read-only credentials. Manual `terraform apply` needs to be performed for changes to be deployed.

```
gcloud config set project projects-seriousben
gcloud auth application-default login
terraform plan
terraform apply
```
