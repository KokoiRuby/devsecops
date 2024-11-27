apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tekton-dashboard
  namespace: tekton-pipelines
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
spec:
  rules:
    - host: tekton.${prefix}.${domain}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: tekton-dashboard
                port:
                  number: 9097
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tekton-github-event-listener
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
spec:
  rules:
    - host: tekton.${prefix}.${domain}
      http:
        paths:
          - path: /hooks
            pathType: Prefix
            backend:
              service:
                name: el-github-devsecops-demo-app
                port:
                  number: 8080