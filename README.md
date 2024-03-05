---
## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

---
## Этапы выполнения:


### Создание облачной инфраструктуры

Для начала необходимо подготовить облачную инфраструктуру в ЯО при помощи [Terraform](https://www.terraform.io/).

Особенности выполнения:

- Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
  Для облачного k8s используйте региональный мастер(неотказоустойчивый). Для self-hosted k8s минимизируйте ресурсы ВМ и долю ЦПУ. В обоих вариантах используйте прерываемые ВМ для worker nodes.
- Следует использовать версию [Terraform](https://www.terraform.io/) не старше 1.5.x .

Предварительная подготовка к установке и запуску Kubernetes кластера.

1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
   ```bash
   > $ yc iam service-account list                                                      [±main ●●●]
   +----------------------+----------+
   |          ID          |   NAME   |
   +----------------------+----------+
   | aje8fv9jqca83bft043u | kuber-sa |
   +----------------------+----------+
   ```
2. Подготовьте [backend](https://www.terraform.io/docs/language/settings/backends/index.html) для Terraform:  
   а. Рекомендуемый вариант: S3 bucket в созданном ЯО аккаунте(создание бакета через TF)
   ```bash
   terraform {
     backend "s3" {
       endpoints = {
         s3 = "https://storage.yandexcloud.net"
       }
       bucket = "state-diplom"
       region = "ru-central1"
       key    = "terraform/terraform.tfstate"

       skip_region_validation      = true
       skip_credentials_validation = true
       skip_requesting_account_id  = true
       skip_s3_checksum            = true
     }
   }
   ```
   б. Альтернативный вариант:  [Terraform Cloud](https://app.terraform.io/)
3. Создайте VPC с подсетями в разных зонах доступности.
   ```bash
   > $ yc vpc network list                                                              [±main ●●●]
   +----------------------+--------+
   |          ID          |  NAME  |
   +----------------------+--------+
   | enpve5tliudk6m9ngvun | diplom |
   +----------------------+--------+
   ```
   ```bash
   > $ yc vpc subnet list                                                               [±main ●●●]
   +----------------------+-------------+----------------------+----------------+---------------+-----------------+
   |          ID          |   NAME      |      NETWORK ID      | ROUTE TABLE ID |     ZONE      |      RANGE      |
   +----------------------+-------------+----------------------+----------------+---------------+-----------------+
   | e2li08d7ots1kf5e4vgq | public-b    | enpve5tliudk6m9ngvun |                | ru-central1-b | [10.10.20.0/24] |
   | e9blg94jkrediv7oblhk | public-a    | enpve5tliudk6m9ngvun |                | ru-central1-a | [10.10.10.0/24] |
   | fl89mm277g2kaqn7qks1 | public-d    | enpve5tliudk6m9ngvun |                | ru-central1-d | [10.10.30.0/24] |
   +----------------------+-----------------------------------------------------------+----------------------+----------------+---------------+-----------------+

   ```
4. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
   ```bash
   > $ terraform apply -auto-approve                                                    [±main ●●●]
   yandex_vpc_network.diplom: Refreshing state... [id=enpve5tliudk6m9ngvun]
   yandex_kms_symmetric_key.kms-key: Refreshing state... [id=abjq0lc9av18ri9qut9d]
   ...........
   helm_release.kube-prometheus-stack: Still creating... [1m40s elapsed]
   helm_release.kube-prometheus-stack: Creation complete after 1m49s [id=prometheus-stack]
   
   Apply complete! Resources: 17 added, 0 changed, 0 destroyed.
   ```

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.
5. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://www.terraform.io/docs/language/settings/backends/index.html) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

Ожидаемые результаты:

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий.
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

---
### Создание Kubernetes кластера

На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфраструктуры.   Требуется обеспечить доступ к ресурсам из Интернета.

Это можно сделать двумя способами:

1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.  
   а. При помощи Terraform подготовить как минимум 3 виртуальных машины Compute Cloud для создания Kubernetes-кластера. Тип виртуальной машины следует выбрать самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.  
   б. Подготовить [ansible](https://www.ansible.com/) конфигурации, можно воспользоваться, например [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)  
   в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.
2. Альтернативный вариант: воспользуйтесь сервисом [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)  
   а. С помощью terraform resource для [kubernetes](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) создать **региональный** мастер kubernetes с размещением нод в разных 3 подсетях
   ```bash
   resource "yandex_kubernetes_cluster" "kuber" {
   network_id              = yandex_vpc_network.diplom.id
   service_account_id      = var.sa
   node_service_account_id = var.sa
   release_channel         = "STABLE"
   .......
   ```
   б. С помощью terraform resource для [kubernetes node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)
   ```bash
   resource "yandex_kubernetes_node_group" "k8s" {
   cluster_id  = "${yandex_kubernetes_cluster.kuber.id}"
   name        = "k8s-cluster"
   version     = "1.28"
   .......
   ```
Ожидаемый результат:

1. Работоспособный Kubernetes кластер.
2. В файле `~/.kube/config` находятся данные для доступа к кластеру.
3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.
   ```bash
   > $ kubectl get pods --all-namespaces                                                                                                                                                           [±main ●●●]
   NAMESPACE               NAME                                                     READY   STATUS    RESTARTS   AGE
   kube-system             coredns-5d4bf4fdc8-6gqbh                                 1/1     Running   0          67m
   kube-system             coredns-5d4bf4fdc8-b4zv6                                 1/1     Running   0          71m
   kube-system             ingress-nginx-controller-6dc8c8fdf4-cvczj                1/1     Running   0          67m
   kube-system             ip-masq-agent-fxl5t                                      1/1     Running   0          68m
   kube-system             ip-masq-agent-rdmwn                                      1/1     Running   0          68m
   kube-system             ip-masq-agent-ws6p9                                      1/1     Running   0          68m
   kube-system             kube-dns-autoscaler-74d99dd8dc-4cwhm                     1/1     Running   0          71m
   kube-system             kube-proxy-dwgvm                                         1/1     Running   0          68m
   kube-system             kube-proxy-mxcr9                                         1/1     Running   0          68m
   kube-system             kube-proxy-sntv5                                         1/1     Running   0          68m
   kube-system             metrics-server-6b5df79959-qvwtg                          2/2     Running   0          67m
   kube-system             npd-v0.8.0-7qcfg                                         1/1     Running   0          68m
   kube-system             npd-v0.8.0-bl89j                                         1/1     Running   0          68m
   kube-system             npd-v0.8.0-r84bp                                         1/1     Running   0          68m
   kube-system             yc-disk-csi-node-v2-5jwp8                                6/6     Running   0          68m
   kube-system             yc-disk-csi-node-v2-66tzv                                6/6     Running   0          68m
   kube-system             yc-disk-csi-node-v2-hbpbf                                6/6     Running   0          68m
   ```

---
### Создание тестового приложения

Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.

Способ подготовки:

1. Рекомендуемый вариант:  
   а. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.    
   [git-repo](https://gitlab.com/Rain-m-a-n/web.git)  
   б. Подготовьте Dockerfile для создания образа приложения.
   ```bash
   FROM nginx:1.25.3

   RUN apt-get update && apt-get -y upgrade && apt-get clean

   COPY index.html hero.jpg /usr/share/nginx/html/

   COPY nginx.conf /etc/nginx/conf.d/default.conf

   CMD ["nginx", "-g", "daemon off;"]
   ```
2. Альтернативный вариант:  
   а. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.

Ожидаемый результат:

1. Git репозиторий с тестовым приложением и Dockerfile.  
   ![git-repo](https://gitlab.com/Rain-m-a-n/diplom/blob/main/pics/git-web.png)  
3. Регистри с собранным docker image. В качестве регистри может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform.  
   ![docker-hub](https://gitlab.com/Rain-m-a-n/diplom/blob/main/pics/dockerhub.png)  

---
### Подготовка cистемы мониторинга и деплой приложения

Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.  
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.

Цель:
1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортер](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
2. Задеплоить тестовое приложение, например, [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.

Способ выполнения:
1. Воспользовать пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), который уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter). При желании можете собрать все эти приложения отдельно.
2. Для организации конфигурации использовать [qbec](https://qbec.io/), основанный на [jsonnet](https://jsonnet.org/). Обратите внимание на имеющиеся функции для интеграции helm конфигов и [helm charts](https://helm.sh/)
3. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте и настройте в кластере [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры. Альтернативный вариант 3 задания: вместо Terraform Cloud или atlantis настройте на автоматический запуск и применение конфигурации terraform из вашего git-репозитория в выбранной вами CI-CD системе при любом комите в main ветку. Предоставьте скриншоты работы пайплайна из CI/CD системы.

Ожидаемый результат:
1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.  
   [repo](https://gitlab.com/Rain-m-a-n/diplom)
2. Http доступ к web интерфейсу grafana.
   * т.к. нет доступа к созданию DNS записей, добавил в `/etc/hosts` 
   ```bash
   > $ cat /etc/hosts                                                           [±main ✓]
   ##
   # Host Database
   #
   # localhost is used to configure the loopback interface
   # when the system is booting.  Do not change this entry.
   ##
   127.0.0.1	localhost
   255.255.255.255	broadcasthost
   ::1             localhost

   158.160.136.201 grafana.diplom.netology
   158.160.136.201 web.diplom.netology
   ```
   ![grafana](https://gitlab.com/Rain-m-a-n/diplom/blob/main/pics/grafana-http.png)  
3. Дашборды в grafana отображающие состояние Kubernetes кластера.  
   ![dashboard](https://gitlab.com/Rain-m-a-n/diplom/blob/main/pics/dashboard.png)  
4. Http доступ к тестовому приложению.  
   ![web](https://gitlab.com/Rain-m-a-n/diplom/blob/main/pics/web.png)  

---
### Установка и настройка CI/CD

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:

1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
2. Автоматический деплой нового docker образа.

Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/), [GitLab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/) или GitHub Actions.

Ожидаемый результат:

1. Интерфейс ci/cd сервиса доступен по http.  
   ![ci](https://gitlab.com/Rain-m-a-n/diplom/blob/main/pics/ci.png)    
2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.  
   ![commit](https://gitlab.com/Rain-m-a-n/diplom/blob/main/pics/commit.png)  
3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистри, а также деплой соответствующего Docker образа в кластер Kubernetes.  
   ![cd](https://github.com/Rain-m-a-n/diplom/blob/main/pics/cd.png)  
   ![dockerhub01](https://github.com/Rain-m-a-n/diplom/blob/main/pics/dockerhub01.png)
   
