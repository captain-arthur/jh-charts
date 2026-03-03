# jh-charts

Helm 차트 저장소. 테스트용 클러스터에 빠르게 모니터링을 구성하기 위한 경량 차트를 제공합니다.

---

## charts/monitoring

Prometheus, node-exporter, kube-state-metrics, Grafana를 한 번에 배포하는 단일 차트입니다.  
복잡한 기능 없이 핵심 객체만 포함하며, **이미지 저장소/버전 변경**과 **폐쇄망 배포**를 쉽게 할 수 있도록 구성되어 있습니다.

| 컴포넌트 | 역할 |
|----------|------|
| Prometheus | 메트릭 수집·저장 |
| node-exporter | 노드(호스트) 메트릭 (DaemonSet) |
| kube-state-metrics | Kubernetes 객체 상태 메트릭 |
| Grafana | 대시보드·조회 (Prometheus 데이터소스 + 기본 대시보드 자동 프로비저닝) |

### 요구사항

- Kubernetes 1.21+
- Helm 3
- `kubectl`이 대상 클러스터를 가리키고 있어야 함 (`kubectl config current-context` 확인)

### 다른 클러스터에서 배포 (최소 절차)

아래만 있으면 **어떤 클러스터에서든** 동일하게 배포할 수 있습니다.

1. 이 저장소를 clone 하거나 압축을 풀어 `charts/monitoring` 경로를 확보합니다.
2. 대상 클러스터로 컨텍스트를 맞춘 뒤 아래 명령을 실행합니다.

```bash
# 저장소 루트에서 실행 (charts/monitoring 이 있는 디렉터리)
kubectl create namespace monitoring
helm install monitoring ./charts/monitoring -n monitoring
```

- **Release 이름 변경**: `monitoring` 대신 원하는 이름 사용 가능. 서비스/파드 이름은 `<release이름>-prometheus` 등으로 붙습니다.
- **다른 네임스페이스**: `-n monitoring`을 `-n <원하는네임스페이스>`로 바꾸면 됩니다.

### 로컬에서 접속 (Grafana / Prometheus)

클러스터 외부에서 접속하려면 포트포워드 후 브라우저로 접속합니다.

```bash
# Grafana (기본 계정: admin / 비밀번호: values.yaml 의 grafana.adminPassword, 기본값 "admin")
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:3000

# Prometheus (선택)
kubectl port-forward -n monitoring svc/monitoring-prometheus 9090:9090
```

- Grafana: http://localhost:3000  
  - 왼쪽 메뉴 **Monitoring** 폴더 → **Monitoring - 전체 메트릭** 대시보드가 프로비저닝되어 있습니다.
- Prometheus: http://localhost:9090

### 이미지 저장소·버전 변경

`values.yaml`에서 각 컴포넌트별로 다음을 수정하면 됩니다.

- **개별 설정**: `prometheus.image`, `nodeExporter.image`, `kubeStateMetrics.image`, `grafana.image`
  - `registry`: 레지스트리 주소 (비우면 공개 레지스트리)
  - `repository`: 이미지 저장소 경로
  - `tag`: 이미지 태그
- **공통 레지스트리**: `global.imageRegistry`에 한 번만 지정하면 모든 컴포넌트에 적용됩니다.

예시 (사설 레지스트리 + 버전 고정):

```yaml
global:
  imageRegistry: "registry.example.com:5000"

prometheus:
  image:
    repository: prom/prometheus
    tag: "v2.47.0"
```

또는 설치 시 오버라이드:

```bash
helm install monitoring ./charts/monitoring -n monitoring \
  --set global.imageRegistry=registry.example.com:5000 \
  --set prometheus.image.tag=v2.46.0
```

### 폐쇄망 배포

1. **이미지 미리 푸시**  
   폐쇄망에서 접근 가능한 사설 레지스트리에 아래 이미지를 푸시합니다.

   | 컴포넌트 | 기본 이미지 |
   |----------|-------------|
   | Prometheus | `prom/prometheus:v2.47.0` |
   | node-exporter | `prom/node-exporter:v1.6.1` |
   | kube-state-metrics | `registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.10.1` |
   | Grafana | `grafana/grafana:10.2.2` |

2. **values 설정**  
   `global.imageRegistry` 또는 각 컴포넌트의 `image.registry`에 사설 레지스트리 주소를 넣습니다.

   ```yaml
   global:
     imageRegistry: "내부레지스트리:5000"
   ```

3. **설치**  
   위와 동일하게 `helm install` 실행. 이미지는 사설 레지스트리에서만 pull 되므로, 이미지만 미리 넣어 두면 배포 가능합니다.

   ```bash
   helm install monitoring ./charts/monitoring -n monitoring -f my-values.yaml
   ```

### 컴포넌트 비활성화

필요 없는 컴포넌트는 `values.yaml`에서 `enabled: false`로 끌 수 있습니다.

```yaml
grafana:
  enabled: false
```

### 업그레이드 / 제거

```bash
# 차트 수정 후 반영
helm upgrade monitoring ./charts/monitoring -n monitoring

# 제거
helm uninstall monitoring -n monitoring
# 네임스페이스까지 삭제하려면: kubectl delete namespace monitoring
```

### 배포 후 확인

- Prometheus 타겟: `http://<prometheus-svc>:9090/targets` (또는 port-forward 후 http://localhost:9090/targets)
- Grafana: **Monitoring** 폴더의 **Monitoring - 전체 메트릭** 대시보드에서 노드/Pod/메트릭 확인
- Grafana Explore: Prometheus 데이터소스 선택 후 메트릭 조회 (예: `up`, `node_cpu_seconds_total`, `kube_pod_info`)
