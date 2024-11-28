apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: grafana
  namespace: loki-stack
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
spec:
  rules:
    - host: grafana.${prefix}.${domain}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: grafana
                port:
                  number: 3000
