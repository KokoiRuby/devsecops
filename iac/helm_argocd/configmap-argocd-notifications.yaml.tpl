# https://argo-cd.readthedocs.io/en/stable/operator-manual/notifications/
# https://argo-cd.readthedocs.io/en/stable/operator-manual/notifications/services/webhook/
kind: ConfigMap
apiVersion: v1
metadata:
  name: argocd-notifications-cm
  namespace: argocd
data:
  context: |
    argocdUrl: http://argocd.${prefix}.${domain}/
  service.webhook.github-webhook: |
    url: https://api.github.com
    headers:
    - name: Authorization
      value: Bearer $github_pat
    subscriptions: |
      - recipients
        - github-webhook
        triggers:
        - on-sync-succeeded
  # TODO: http://demo-app.<ns>.<project>.<domain>
  template.app-sync-succeeded: |
    webhook:
      github-webhook:
        method: POST
        path: /repos/{{.app.metadata.annotations.githubOwner}}/{{.app.metadata.annotations.githubRepo}}/issues/{{.app.metadata.annotations.prNumber}}/comments
        body: |
          {
            "body": "Preview environment is ready at: \nhttp://demo-app.{{.app.spec.destination.namespace}}.{{.app.metadata.annotations.prPreviewHost}}/foo\nhttp://demo-app.{{.app.spec.destination.namespace}}.{{.app.metadata.annotations.prPreviewHost}}/bar"
          }
  trigger.on-sync-succeeded: |
    - description: Application syncing has succeeded
      send:
      - app-sync-succeeded
      when: app.status.operationState.phase in ['Succeeded'] and app.status.health.status == 'Healthy'
      oncePer: app.status.operationState.syncResult.revision
