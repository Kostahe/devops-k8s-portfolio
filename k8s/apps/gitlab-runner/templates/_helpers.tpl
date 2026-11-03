{{- define "gitlab-runner.name" -}}
{{- default .Chart.Name .Values.runnerName | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "gitlab-runner.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "gitlab-runner.name" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}
