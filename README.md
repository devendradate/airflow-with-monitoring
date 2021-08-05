# Airflow Deployment using Helm on EKS with Prometheus and Grafana monitoring

## **Prerequisites**

1. subnet_id in eks-worker-node.tf and eks.tf
2. aws keys removed in final.yaml
3. sshknownhost updated in final.yaml
4. id_rsa file content removed
5. variable.tf file updated

## **Steps**
```bash
terraform init
terraform validate
terraform apply
```
<img width="774" alt="Screenshot 2021-08-05 at 12 01 49 PM" src="https://user-images.githubusercontent.com/88183601/128302523-2416b1aa-0a9b-4120-9a81-56543a0ea12b.png">


you will be asked to put aws profile name for validation and then the whole cluster will be setup automatically.


Once the setup is done, open the grafana UI and import dashbaord json file from file "default/airflow-dashboard.json"

For EKS Cluster login and Airflow UI
```
aws eks --region ap-south-1 update-kubeconfig --name test --profile <profile_name>
kubectl port-forward svc/airflow-stable-web 8080:8080 -n airflow (admin:admin)
```
<img width="1438" alt="Screenshot 2021-08-05 at 12 03 36 PM" src="https://user-images.githubusercontent.com/88183601/128302684-45495e52-8d03-4606-a69a-023fa13c90cb.png">


for metrics
```
http://localhost:8080/admin/metrics/
```
<img width="1266" alt="Screenshot 2021-08-05 at 12 04 18 PM" src="https://user-images.githubusercontent.com/88183601/128302777-514dc234-80e5-4152-b519-4e05b4b6cd65.png">



For Grafana Login
```
kubectl get secret --namespace airflow monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo (for password)
kubectl port-forward svc/monitoring-grafana 3000:80 -n airflow
```

<img width="1326" alt="Screenshot 2021-08-05 at 12 06 01 PM" src="https://user-images.githubusercontent.com/88183601/128302978-164c8ace-d7be-4b70-8b5b-9b1d2e265055.png">


Import Dashboard using "default/airflow-dashboard.json" file

<img width="1439" alt="Screenshot 2021-08-05 at 12 06 32 PM" src="https://user-images.githubusercontent.com/88183601/128303030-31188437-8dee-47bc-85e4-e51d8f9af1f7.png">


## **Files and their working,**

```1. configmap.yaml```

It contains the grafana dashboard JSON for Airflow

```2. eks-worker-node.tf```

It contains code for IAM Roles for Nodes and Node Group creation 

```3. eks.tf```

It contains the code to create EKS cluster on AWS

```4. final.yaml```

It is values file for Airflow Community Chart

```5. helm.tf```

It creates a Helm chart for Airflow and Prometheus/Grafana

```6. kubernetes.tf```

It create namespace, secret and configmap in Kubernetes which is required by helm installation

```7. loki.yaml```

It is values file for Prometheus/Grafana/Loki Chart

```8. output.tf```

It stores outputs of the cluster

```9. providers.tf```

configured AWS provider

```10. variables.tf```

configured variables used in terraform 

```11. vpc.tf```

take vpc id from variable file

