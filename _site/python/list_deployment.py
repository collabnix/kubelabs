from kubernetes import client, config

config.load_kube_config()
api = client.AppsV1Api()

deployments = api.list_namespaced_deployment(namespace='default')
for deployment in deployments.items:
    print(deployment.metadata.name)
