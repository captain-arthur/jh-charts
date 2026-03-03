# monitoring 차트

경량 모니터링 스택: Prometheus, node-exporter, kube-state-metrics, Grafana.  
기본 대시보드가 프로비저닝되며, 이미지/폐쇄망 설정이 단순합니다.

**다른 클러스터에서 배포**: 저장소 루트에서 `kubectl create namespace monitoring && helm install monitoring ./charts/monitoring -n monitoring` 실행.  
(사전 요구: Kubernetes 1.21+, Helm 3, `kubectl`이 해당 클러스터를 가리킴)

| 항목 | 설명 |
|------|------|
| 이미지 | `values.yaml`의 `global.imageRegistry` 또는 각 컴포넌트 `image.registry` / `repository` / `tag` |
| 폐쇄망 | 사설 레지스트리 주소 지정 후, 해당 레지스트리에 이미지 미리 푸시한 뒤 동일하게 `helm install` |
| 비활성화 | 컴포넌트별 `enabled: false` (예: `grafana.enabled: false`) |

상세 사용법·폐쇄망 이미지 목록·업그레이드/제거는 저장소 루트 [README.md](../../README.md) 참고.
