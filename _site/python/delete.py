from kubernetes import client, config

config.load_kube_config()
api = client.AppsV1Api()

api.delete_namespaced_deployment(name='my-deployment', namespace='default')
