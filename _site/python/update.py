from kubernetes import client, config

config.load_kube_config()
api = client.AppsV1Api()

deployment = api.read_namespaced_deployment(name='my-deployment', namespace='default')
deployment.spec.replicas = 5

api.patch_namespaced_deployment(name='my-deployment', namespace='default', body=deployment)
