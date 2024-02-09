# Дипломный практикум в Yandex.Cloud

---
## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

---

### Создание облачной инфраструктуры

Для начала необходимо подготовить облачную инфраструктуру в ЯО при помощи [Terraform](https://www.terraform.io/).

Особенности выполнения:

- Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
Для облачного k8s используйте региональный мастер(неотказоустойчивый). Для self-hosted k8s минимизируйте ресурсы ВМ и долю ЦПУ. В обоих вариантах используйте прерываемые ВМ для worker nodes.
- Следует использовать версию [Terraform](https://www.terraform.io/) не старше 1.5.x .

Предварительная подготовка к установке и запуску Kubernetes кластера.

1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
2. Подготовьте [backend](https://www.terraform.io/docs/language/settings/backends/index.html) для Terraform:  
   а. Рекомендуемый вариант: S3 bucket в созданном ЯО аккаунте(создание бакета через TF)
   б. Альтернативный вариант:  [Terraform Cloud](https://app.terraform.io/)  
3. Создайте VPC с подсетями в разных зонах доступности.
4. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
5. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://www.terraform.io/docs/language/settings/backends/index.html) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.


<details>
<summary>Решение</summary>
<br>   

 Подготовлена конфигурация согласно требованиям:
 [accaunt](terraform-compute-cloud/sa.tf)   
 [bucket](terraform-compute-cloud/bucket.tf)   
 [vpc](terraform-compute-cloud/main.tf)   
 Так же по результатам работы `terraform apply` будет сформирован [инветории и конфиги](terraform-compute-cloud/infentory.tf) для Kubespray и
выведены в [output](terraform-compute-cloud/outputs.tf) необходимы данные для последующей инициализации S3 bucket и подключения к K8S кластеру.   

Проверяем отработку команд `terraform destroy` и `terraform apply`   
[terraform apply log](terraform-compute-cloud/log/apply.log)   
[terraform destroy log](terraform-compute-cloud/log/destroy.log)   

По результатам отработки `terraform apply`  была создана следующая инфраструктура: 

````   
yandex_iam_service_account.tech-account: Creating...
yandex_vpc_network.my-k8s-net: Creating...
yandex_iam_service_account.bucket-account: Creating...
yandex_compute_image.ubuntu-test: Creating...
yandex_dns_zone.diplom: Creating...
yandex_dns_zone.diplom: Creation complete after 0s [id=dns4eho7a1knaejq1ku0]
yandex_vpc_network.my-k8s-net: Creation complete after 2s [id=enp1n5dt1ren1kp5hasa]
yandex_vpc_subnet.mysubnet-d: Creating...
yandex_vpc_subnet.mysubnet-b: Creating...
yandex_vpc_subnet.mysubnet-a: Creating...
yandex_iam_service_account.tech-account: Creation complete after 2s [id=aje7keuov0demoru8fna]
yandex_resourcemanager_folder_iam_member.k8s-editor: Creating...
yandex_vpc_subnet.mysubnet-b: Creation complete after 1s [id=e2lgjfin94j46rmh7d0g]
yandex_vpc_subnet.mysubnet-a: Creation complete after 2s [id=e9b5na1gkdf634o0km07]
yandex_vpc_subnet.mysubnet-d: Creation complete after 2s [id=fl8d7ve6viq4o5l35hm4]
yandex_iam_service_account.bucket-account: Creation complete after 4s [id=ajepfvljcqcdegaeaguq]
yandex_resourcemanager_folder_iam_member.bucket-account: Creating...
yandex_iam_service_account_static_access_key.bucket-account-key: Creating...
yandex_resourcemanager_folder_iam_member.k8s-editor: Creation complete after 3s [id=b1gb1aal3vgk7p7nr6nd/editor/serviceAccount:aje7keuov0demoru8fna]
yandex_iam_service_account_static_access_key.bucket-account-key: Creation complete after 2s [id=aje7e1clf72poldnc9pg]
yandex_resourcemanager_folder_iam_member.bucket-account: Creation complete after 4s [id=b1gb1aal3vgk7p7nr6nd/storage.admin/serviceAccount:ajepfvljcqcdegaeaguq]
yandex_storage_bucket.project-bucket: Creating...
yandex_compute_image.ubuntu-test: Still creating... [10s elapsed]
yandex_storage_bucket.project-bucket: Creation complete after 3s [id=k8s-tech]
yandex_compute_image.ubuntu-test: Creation complete after 11s [id=fd8hvdone3uuv7448p0h]
yandex_compute_instance_group.k8s-node: Creating...
yandex_compute_instance_group.k8s-node: Still creating... [10s elapsed]
yandex_compute_instance_group.k8s-node: Still creating... [20s elapsed]
yandex_compute_instance_group.k8s-node: Still creating... [30s elapsed]
yandex_compute_instance_group.k8s-node: Still creating... [40s elapsed]
yandex_compute_instance_group.k8s-node: Still creating... [50s elapsed]
yandex_compute_instance_group.k8s-node: Still creating... [1m0s elapsed]
yandex_compute_instance_group.k8s-node: Still creating... [1m10s elapsed]
yandex_compute_instance_group.k8s-node: Still creating... [1m20s elapsed]
yandex_compute_instance_group.k8s-node: Still creating... [1m30s elapsed]
yandex_compute_instance_group.k8s-node: Still creating... [1m40s elapsed]
yandex_compute_instance_group.k8s-node: Creation complete after 1m45s [id=cl1mhmt90llqqlismlba]
yandex_dns_recordset.kas: Creating...
yandex_dns_recordset.registry: Creating...
yandex_dns_recordset.test-app: Creating...
yandex_dns_recordset.minio: Creating...
yandex_dns_recordset.gitlab: Creating...
yandex_dns_recordset.grafana: Creating...
local_file.project: Creating...
local_file.addons: Creating...
local_file.k8s-cluster: Creating...
local_file.addons: Creation complete after 0s [id=ae375bdd85c7ad186378d3507fd64e14b54fa66c]
local_file.k8s-cluster: Creation complete after 0s [id=e7702c0629ad20c7c13eff8a89f2aee93453290f]
local_file.project: Creation complete after 0s [id=454dd23444f380d38d355be6be3c0589ccbbf2d2]
yandex_dns_recordset.gitlab: Creation complete after 0s [id=dns4eho7a1knaejq1ku0/gitlab.tomaev-maksim.ru./A]
yandex_dns_recordset.test-app: Creation complete after 0s [id=dns4eho7a1knaejq1ku0/test-app.tomaev-maksim.ru./A]
yandex_dns_recordset.grafana: Creation complete after 0s [id=dns4eho7a1knaejq1ku0/grafana.tomaev-maksim.ru./A]
yandex_dns_recordset.kas: Creation complete after 1s [id=dns4eho7a1knaejq1ku0/kas.tomaev-maksim.ru./A]
yandex_dns_recordset.minio: Creation complete after 1s [id=dns4eho7a1knaejq1ku0/minio.tomaev-maksim.ru./A]
yandex_dns_recordset.registry: Creation complete after 1s [id=dns4eho7a1knaejq1ku0/registry.tomaev-maksim.ru./A]

Apply complete! Resources: 22 added, 0 changed, 0 destroyed.

Outputs:

access_key = "YCAJEeWBJHVz0bnwx6Zak3Hdd"
external_ip = "158.160.40.229"
secret_key = <sensitive>

````   
![Снимок экрана 2024-02-05 в 20 49 46](https://github.com/tomaevmax/devops-netology/assets/32243921/81ee338c-653e-4ab9-9b6c-65f44841e045)

Для подключения backend S3 внесем правки в [provider.tf](/terraform-compute-cloud/providers.tf)
И проведем инициализацию согласно документации:

````   
➜  terraform-compute-cloud git:(main) ✗ terraform init -backend-config="access_key=YCAJEH2twIBQ59ptKVozJ9pZu" -backend-config="secret_key=YCOZPrEhTXasze6XXBZBGQ5L_5ILw7fPaj3sZYi9"


Initializing the backend...
Do you want to copy existing state to the new backend?
  Pre-existing state was found while migrating the previous "local" backend to the
  newly configured "s3" backend. No existing state was found in the newly
  configured "s3" backend. Do you want to copy this state to the new "s3"
  backend? Enter "yes" to copy and "no" to start with an empty state.

  Enter a value: yes


Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Reusing previous version of yandex-cloud/yandex from the dependency lock file
- Reusing previous version of hashicorp/local from the dependency lock file
- Using previously-installed yandex-cloud/yandex v0.107.0
- Using previously-installed hashicorp/local v2.4.1

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary. 
````   

</details>

---
### Создание Kubernetes кластера

На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфраструктуры.   Требуется обеспечить доступ к ресурсам из Интернета.

Это можно сделать двумя способами:

1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.  
   а. При помощи Terraform подготовить как минимум 3 виртуальных машины Compute Cloud для создания Kubernetes-кластера. Тип виртуальной машины следует выбрать самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.  
   б. Подготовить [ansible](https://www.ansible.com/) конфигурации, можно воспользоваться, например [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)  
   в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.
2. Альтернативный вариант: воспользуйтесь сервисом [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)  
  а. С помощью terraform resource для [kubernetes](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) создать **региональный** мастер kubernetes с размещением нод в разных 3 подсетях      
  б. С помощью terraform resource для [kubernetes node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)


<details>
<summary>Решение</summary>
<br>   
Установку будем производить с помощью [Kubespray](https://kubespray.io/#/) одним из рекомендованных способов, а именно с помощью docker образа.      
После разворачивания инфраструктуры были сформированы [инветории и конфиги](terraform-compute-cloud/infentory.tf).   
Запускаем докер образ следующей командой, сразу монтирую к образу созданные инветори и конфиги:   

````  
➜  terraform-compute-cloud git:(main) ✗ docker run --rm -it --mount type=bind,source="${HOME}"/.ssh/id_ed25519,dst=/root/.ssh/id_rsa --mount type=bind,source="${PWD}"/inventory/hosts.yaml,dst=/kubespray/inventory/my/hosts.yaml --mount type=bind,source="${PWD}"/inventory/addons.yml,dst=/kubespray/inventory/my/group_vars/k8s_cluster/addons.yml --mount type=bind,source="${PWD}"/inventory/k8s-cluster.yml,dst=/kubespray/inventory/my/group_vars/k8s_cluster/k8s-cluster.yml quay.io/kubespray/kubespray:v2.23.1 bash
WARNING: The requested image's platform (linux/amd64) does not match the detected host platform (linux/arm64/v8) and no specific platform was requested
root@872f44fb35dc:/kubespray# cp -rnp inventory/sample/* inventory/my
root@872f44fb35dc:/kubespray# ansible-playbook -i inventory/my/hosts.yaml  -u ubuntu --become  cluster.yml

````   
После копирования остальных конфигурационных файлов в наше инветори внутри образа, запускаем playbook.    
Лог отработки playbook:   
[ansyble log](terraform-compute-cloud/log/ansyble.log)   
Результат отработки playbook
````   
Monday 05 February 2024  17:57:47 +0000 (0:00:00.120)       0:25:32.553 ******* 
=============================================================================== 
download : Download_file | Download item ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 359.31s
download : Download_file | Download item ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ 63.40s
download : Download_file | Download item ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ 34.99s
kubernetes/preinstall : Install packages requirements ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 30.34s
download : Download_file | Download item ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ 29.47s
kubernetes/kubeadm : Join to cluster ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 26.77s
bootstrap-os : Install dbus for the hostname module ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 26.54s
kubernetes-apps/ingress_controller/ingress_nginx : NGINX Ingress Controller | Create manifests ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ 20.30s
kubernetes-apps/ansible : Kubernetes Apps | Lay Down CoreDNS templates ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ 18.98s
download : Download_container | Download image if required ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ 17.37s
download : Download_container | Download image if required ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ 14.24s
kubernetes/preinstall : Update package management cache (APT) --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 13.42s
kubernetes-apps/external_provisioner/local_volume_provisioner : Local Volume Provisioner | Create manifests ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 12.57s
kubernetes-apps/external_provisioner/local_path_provisioner : Local Path Provisioner | Create manifests --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 12.25s
bootstrap-os : Fetch /etc/os-release ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 12.17s
download : Download_container | Download image if required ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ 11.20s
network_plugin/calico : Calico | Create calico manifests -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 10.85s
download : Download_container | Download image if required ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ 10.63s
etcd : Reload etcd ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 10.50s
container-engine/containerd : Download_file | Download item ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 10.38s
root@cd6c31e9fa68:/kubespray# 

```` 

Выполняем подключение к control plane node и копируем admin.conf к себе на локальную ноду.

````
➜  diplom git:(main) ✗ ssh ubuntu@158.160.40.229
Welcome to Ubuntu 22.04.3 LTS (GNU/Linux 5.15.0-92-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

  System information as of Mon Feb  5 06:05:36 PM UTC 2024

  System load:  0.01513671875      Processes:             196
  Usage of /:   13.6% of 58.96GB   Users logged in:       0
  Memory usage: 7%                 IPv4 address for eth0: 10.5.0.34
  Swap usage:   0%

 * Strictly confined Kubernetes makes edge and IoT secure. Learn how MicroK8s
   just raised the bar for easy, resilient and secure K8s cluster deployment.

   https://ubuntu.com/engage/secure-kubernetes-at-the-edge

Expanded Security Maintenance for Applications is not enabled.

0 updates can be applied immediately.

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status


Last login: Mon Feb  5 17:33:04 2024 from 109.248.252.157
ubuntu@node1:~$ sudo cat /etc/kubernetes/admin.conf
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data:  *****
    server: https://127.0.0.1:6443
  name: cluster.local
contexts:
- context:
    cluster: cluster.local
    user: kubernetes-admin
  name: kubernetes-admin@cluster.local
current-context: kubernetes-admin@cluster.local
kind: Config
preferences: {}
users:
- name: kubernetes-admin
  user:
    client-certificate-data: *****
    client-key-data: *****
   
````   
Переносим конфиг к себе на локальный компьютер, заменив server: https://127.0.0.1:6443 на server: https://158.160.40.229:6443
Проверяем отрботку команды 

````  
➜  diplom git:(main) ✗ kubectl get pods --all-namespaces
NAMESPACE            NAME                                       READY   STATUS    RESTARTS   AGE
ingress-nginx        ingress-nginx-controller-jv45m             1/1     Running   0          14m
ingress-nginx        ingress-nginx-controller-k2tdh             1/1     Running   0          14m
ingress-nginx        ingress-nginx-controller-snjwt             1/1     Running   0          14m
kube-system          calico-kube-controllers-794577df96-blhkz   1/1     Running   0          15m
kube-system          calico-node-bmgx8                          1/1     Running   0          15m
kube-system          calico-node-mzcbl                          1/1     Running   0          15m
kube-system          calico-node-tnbls                          1/1     Running   0          15m
kube-system          coredns-5c469774b8-q42j4                   1/1     Running   0          13m
kube-system          coredns-5c469774b8-vpzsv                   1/1     Running   0          13m
kube-system          dns-autoscaler-f455cf558-cr9j8             1/1     Running   0          13m
kube-system          kube-apiserver-node1                       1/1     Running   1          17m
kube-system          kube-controller-manager-node1              1/1     Running   2          17m
kube-system          kube-proxy-rg85m                           1/1     Running   0          16m
kube-system          kube-proxy-x5pbb                           1/1     Running   0          16m
kube-system          kube-proxy-x6c2l                           1/1     Running   0          16m
kube-system          kube-scheduler-node1                       1/1     Running   1          17m
kube-system          local-volume-provisioner-4tprs             1/1     Running   0          14m
kube-system          local-volume-provisioner-65449             1/1     Running   0          14m
kube-system          local-volume-provisioner-cf9l6             1/1     Running   0          14m
kube-system          nginx-proxy-node2                          1/1     Running   0          16m
kube-system          nginx-proxy-node3                          1/1     Running   0          16m
kube-system          nodelocaldns-bsltn                         1/1     Running   0          13m
kube-system          nodelocaldns-mvcf4                         1/1     Running   0          13m
kube-system          nodelocaldns-r45bd                         1/1     Running   0          13m
local-path-storage   local-path-provisioner-6f7b5796d5-tq6jk    1/1     Running   0          13m

````   
</details>    

---
### Создание тестового приложения

Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.

Способ подготовки:

1. Рекомендуемый вариант:  
   а. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.  
   б. Подготовьте Dockerfile для создания образа приложения.  
2. Альтернативный вариант:  
   а. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.

Ожидаемый результат:

1. Git репозиторий с тестовым приложением и Dockerfile.
2. Регистри с собранным docker image. В качестве регистри может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform.

<details>
<summary>Решение</summary>
<br>  

 Создаем репозитарий на [GitHub](https://github.com/tomaevmax/test-app/tree/main/docker)   
 Собираем и пуши в [DockerHub](https://hub.docker.com/repository/docker/tomaevmax/test-app/general) наше приложение .   
 ````   
➜  docker git:(main) ✗ docker build --platform=linux/amd64 -f Dockerfile -t test-app:1.0.0. . 
[+] Building 1.0s (7/7) FINISHED                                                                                                                                                                                                                                                              docker:desktop-linux
 => [internal] load .dockerignore                                                                                                                                                                                                                                                                             0.0s
 => => transferring context: 2B                                                                                                                                                                                                                                                                               0.0s
 => [internal] load build definition from Dockerfile                                                                                                                                                                                                                                                          0.0s
 => => transferring dockerfile: 93B                                                                                                                                                                                                                                                                           0.0s
 => [internal] load metadata for docker.io/library/nginx:stable                                                                                                                                                                                                                                               0.9s
 => [internal] load build context                                                                                                                                                                                                                                                                             0.0s
 => => transferring context: 32B                                                                                                                                                                                                                                                                              0.0s
 => [1/2] FROM docker.io/library/nginx:stable@sha256:eb0007fd8cb8cce31771a87b8be09a3b7099ca50527ab3098a2cde9ccfafe747                                                                                                                                                                                         0.0s
 => CACHED [2/2] COPY index.html /usr/share/nginx/html/                                                                                                                                                                                                                                                       0.0s
 => exporting to image                                                                                                                                                                                                                                                                                        0.0s
 => => exporting layers                                                                                                                                                                                                                                                                                       0.0s
 => => writing image sha256:a83c995960cd9bf0e6abd5718182deba3c9331eaea5589941674301e2263c5b2                                                                                                                                                                                                                  0.0s
 => => naming to docker.io/library/test-app:1.0.0.                                                                                                                                                                                                                                                            0.0s

What's Next?
  View summary of image vulnerabilities and recommendations → docker scout quickview
➜  docker git:(main) ✗ docker tag test-app:1.0.0. tomaevmax/test-app:1.0.0                   
➜  docker git:(main) ✗ docker push tomaevmax/test-app:1.0.0                   
The push refers to repository [docker.io/tomaevmax/test-app]
43e8128f7ec8: Pushed 
1e9dec811b0e: Mounted from library/nginx 
26343c662928: Mounted from library/nginx 
41c89c58dd77: Mounted from library/nginx 
0353a20b40d7: Mounted from library/nginx 
abc76e6033f5: Mounted from library/nginx 
30e7249f6651: Mounted from library/nginx 
1.0.0: digest: sha256:06d4a0ca4321662ec2f4b07fde0a6b445cf91ed5592bc217c5fd38c33d243854 size: 1777
➜  docker git:(main) ✗ 

 ````

</details>    

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
2. Http доступ к web интерфейсу grafana.
3. Дашборды в grafana отображающие состояние Kubernetes кластера.
4. Http доступ к тестовому приложению.


<details>
<summary>Решение</summary>
<br>  

Установку кластера prometeus будем производить с помощью пакета [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus)   
От себя добавим туда конфиг ingress и подправим политику 

````   
➜  kube-prometheus git:(main) kubectl apply --server-side -f manifests/setup
customresourcedefinition.apiextensions.k8s.io/alertmanagerconfigs.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/alertmanagers.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/podmonitors.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/probes.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/prometheuses.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/prometheusagents.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/prometheusrules.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/scrapeconfigs.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/servicemonitors.monitoring.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/thanosrulers.monitoring.coreos.com serverside-applied
namespace/monitoring serverside-applied
➜  kube-prometheus git:(main) kubectl wait \
        --for condition=Established \
        --all CustomResourceDefinition \
        --namespace=monitoring
customresourcedefinition.apiextensions.k8s.io/alertmanagerconfigs.monitoring.coreos.com condition met
customresourcedefinition.apiextensions.k8s.io/alertmanagers.monitoring.coreos.com condition met
customresourcedefinition.apiextensions.k8s.io/bgpconfigurations.crd.projectcalico.org condition met
customresourcedefinition.apiextensions.k8s.io/bgppeers.crd.projectcalico.org condition met
customresourcedefinition.apiextensions.k8s.io/blockaffinities.crd.projectcalico.org condition met
customresourcedefinition.apiextensions.k8s.io/caliconodestatuses.crd.projectcalico.org condition met
customresourcedefinition.apiextensions.k8s.io/clusterinformations.crd.projectcalico.org condition met
customresourcedefinition.apiextensions.k8s.io/felixconfigurations.crd.projectcalico.org condition met
customresourcedefinition.apiextensions.k8s.io/globalnetworkpolicies.crd.projectcalico.org condition met
customresourcedefinition.apiextensions.k8s.io/globalnetworksets.crd.projectcalico.org condition met
customresourcedefinition.apiextensions.k8s.io/hostendpoints.crd.projectcalico.org condition met
customresourcedefinition.apiextensions.k8s.io/ipamblocks.crd.projectcalico.org condition met
customresourcedefinition.apiextensions.k8s.io/ipamconfigs.crd.projectcalico.org condition met
customresourcedefinition.apiextensions.k8s.io/ipamhandles.crd.projectcalico.org condition met
customresourcedefinition.apiextensions.k8s.io/ippools.crd.projectcalico.org condition met
customresourcedefinition.apiextensions.k8s.io/ipreservations.crd.projectcalico.org condition met
customresourcedefinition.apiextensions.k8s.io/kubecontrollersconfigurations.crd.projectcalico.org condition met
customresourcedefinition.apiextensions.k8s.io/networkpolicies.crd.projectcalico.org condition met
customresourcedefinition.apiextensions.k8s.io/networksets.crd.projectcalico.org condition met
customresourcedefinition.apiextensions.k8s.io/podmonitors.monitoring.coreos.com condition met
customresourcedefinition.apiextensions.k8s.io/probes.monitoring.coreos.com condition met
customresourcedefinition.apiextensions.k8s.io/prometheusagents.monitoring.coreos.com condition met
customresourcedefinition.apiextensions.k8s.io/prometheuses.monitoring.coreos.com condition met
customresourcedefinition.apiextensions.k8s.io/prometheusrules.monitoring.coreos.com condition met
customresourcedefinition.apiextensions.k8s.io/scrapeconfigs.monitoring.coreos.com condition met
customresourcedefinition.apiextensions.k8s.io/servicemonitors.monitoring.coreos.com condition met
customresourcedefinition.apiextensions.k8s.io/thanosrulers.monitoring.coreos.com condition met
➜  kube-prometheus git:(main) kubectl apply -f manifests/
alertmanager.monitoring.coreos.com/main created
networkpolicy.networking.k8s.io/alertmanager-main created
poddisruptionbudget.policy/alertmanager-main created
prometheusrule.monitoring.coreos.com/alertmanager-main-rules created
secret/alertmanager-main created
service/alertmanager-main created
serviceaccount/alertmanager-main created
servicemonitor.monitoring.coreos.com/alertmanager-main created
clusterrole.rbac.authorization.k8s.io/blackbox-exporter created
clusterrolebinding.rbac.authorization.k8s.io/blackbox-exporter created
configmap/blackbox-exporter-configuration created
deployment.apps/blackbox-exporter created
networkpolicy.networking.k8s.io/blackbox-exporter created
service/blackbox-exporter created
serviceaccount/blackbox-exporter created
servicemonitor.monitoring.coreos.com/blackbox-exporter created
secret/grafana-config created
secret/grafana-datasources created
configmap/grafana-dashboard-alertmanager-overview created
configmap/grafana-dashboard-apiserver created
configmap/grafana-dashboard-cluster-total created
configmap/grafana-dashboard-controller-manager created
configmap/grafana-dashboard-grafana-overview created
configmap/grafana-dashboard-k8s-resources-cluster created
configmap/grafana-dashboard-k8s-resources-multicluster created
configmap/grafana-dashboard-k8s-resources-namespace created
configmap/grafana-dashboard-k8s-resources-node created
configmap/grafana-dashboard-k8s-resources-pod created
configmap/grafana-dashboard-k8s-resources-workload created
configmap/grafana-dashboard-k8s-resources-workloads-namespace created
configmap/grafana-dashboard-kubelet created
configmap/grafana-dashboard-namespace-by-pod created
configmap/grafana-dashboard-namespace-by-workload created
configmap/grafana-dashboard-node-cluster-rsrc-use created
configmap/grafana-dashboard-node-rsrc-use created
configmap/grafana-dashboard-nodes-darwin created
configmap/grafana-dashboard-nodes created
configmap/grafana-dashboard-persistentvolumesusage created
configmap/grafana-dashboard-pod-total created
configmap/grafana-dashboard-prometheus-remote-write created
configmap/grafana-dashboard-prometheus created
configmap/grafana-dashboard-proxy created
configmap/grafana-dashboard-scheduler created
configmap/grafana-dashboard-workload-total created
configmap/grafana-dashboards created
deployment.apps/grafana created
ingress.networking.k8s.io/grafana-ingress created
networkpolicy.networking.k8s.io/grafana created
prometheusrule.monitoring.coreos.com/grafana-rules created
service/grafana created
serviceaccount/grafana created
servicemonitor.monitoring.coreos.com/grafana created
prometheusrule.monitoring.coreos.com/kube-prometheus-rules created
clusterrole.rbac.authorization.k8s.io/kube-state-metrics created
clusterrolebinding.rbac.authorization.k8s.io/kube-state-metrics created
deployment.apps/kube-state-metrics created
networkpolicy.networking.k8s.io/kube-state-metrics created
prometheusrule.monitoring.coreos.com/kube-state-metrics-rules created
service/kube-state-metrics created
serviceaccount/kube-state-metrics created
servicemonitor.monitoring.coreos.com/kube-state-metrics created
prometheusrule.monitoring.coreos.com/kubernetes-monitoring-rules created
servicemonitor.monitoring.coreos.com/kube-apiserver created
servicemonitor.monitoring.coreos.com/coredns created
servicemonitor.monitoring.coreos.com/kube-controller-manager created
servicemonitor.monitoring.coreos.com/kube-scheduler created
servicemonitor.monitoring.coreos.com/kubelet created
clusterrole.rbac.authorization.k8s.io/node-exporter created
clusterrolebinding.rbac.authorization.k8s.io/node-exporter created
daemonset.apps/node-exporter created
networkpolicy.networking.k8s.io/node-exporter created
prometheusrule.monitoring.coreos.com/node-exporter-rules created
service/node-exporter created
serviceaccount/node-exporter created
servicemonitor.monitoring.coreos.com/node-exporter created
clusterrole.rbac.authorization.k8s.io/prometheus-k8s created
clusterrolebinding.rbac.authorization.k8s.io/prometheus-k8s created
networkpolicy.networking.k8s.io/prometheus-k8s created
poddisruptionbudget.policy/prometheus-k8s created
prometheus.monitoring.coreos.com/k8s created
prometheusrule.monitoring.coreos.com/prometheus-k8s-prometheus-rules created
rolebinding.rbac.authorization.k8s.io/prometheus-k8s-config created
rolebinding.rbac.authorization.k8s.io/prometheus-k8s created
rolebinding.rbac.authorization.k8s.io/prometheus-k8s created
rolebinding.rbac.authorization.k8s.io/prometheus-k8s created
role.rbac.authorization.k8s.io/prometheus-k8s-config created
role.rbac.authorization.k8s.io/prometheus-k8s created
role.rbac.authorization.k8s.io/prometheus-k8s created
role.rbac.authorization.k8s.io/prometheus-k8s created
service/prometheus-k8s created
serviceaccount/prometheus-k8s created
servicemonitor.monitoring.coreos.com/prometheus-k8s created
apiservice.apiregistration.k8s.io/v1beta1.metrics.k8s.io created
clusterrole.rbac.authorization.k8s.io/prometheus-adapter created
clusterrole.rbac.authorization.k8s.io/system:aggregated-metrics-reader created
clusterrolebinding.rbac.authorization.k8s.io/prometheus-adapter created
clusterrolebinding.rbac.authorization.k8s.io/resource-metrics:system:auth-delegator created
clusterrole.rbac.authorization.k8s.io/resource-metrics-server-resources created
configmap/adapter-config created
deployment.apps/prometheus-adapter created
networkpolicy.networking.k8s.io/prometheus-adapter created
poddisruptionbudget.policy/prometheus-adapter created
rolebinding.rbac.authorization.k8s.io/resource-metrics-auth-reader created
service/prometheus-adapter created
serviceaccount/prometheus-adapter created
servicemonitor.monitoring.coreos.com/prometheus-adapter created
clusterrole.rbac.authorization.k8s.io/prometheus-operator created
clusterrolebinding.rbac.authorization.k8s.io/prometheus-operator created
deployment.apps/prometheus-operator created
networkpolicy.networking.k8s.io/prometheus-operator created
prometheusrule.monitoring.coreos.com/prometheus-operator-rules created
service/prometheus-operator created
serviceaccount/prometheus-operator created
servicemonitor.monitoring.coreos.com/prometheus-operator created

````   
Проверяем доступность через Http grafana      
````   
➜  diplom git:(main) ✗ kubectl get ingress -A
NAMESPACE    NAME              CLASS   HOSTS                      ADDRESS          PORTS   AGE
monitoring   grafana-ingress   nginx   grafana.tomaev-maksim.ru   158.160.40.229   80      92s

````   

![Снимок экрана 2024-02-05 в 21 45 40](https://github.com/tomaevmax/devops-netology/assets/32243921/b19ab989-c739-4cbe-9818-9007770a5e57)   

Для формирование чартов своего приложения будем использовать [qbec](https://qbec.io/)
Подготовим [компонет](test-app/components/test-app.jsonnet), который будем фофрмировать сразу три сущности: deployments, services, ingresses.   

Произведем установку:
````   
➜  test-app git:(main) ✗ qbec validate default
setting cluster to cluster.local
setting context to kubernetes-admin@cluster.local
cluster metadata load took 213ms
1 components evaluated in 4ms
✔ ingresses test-app -n default (source test-app) is valid
✔ deployments test-app -n default (source test-app) is valid
✔ services test-app -n default (source test-app) is valid
---
stats:
  valid: 3

command took 360ms
➜  test-app git:(main) ✗ qbec apply default   
setting cluster to cluster.local
setting context to kubernetes-admin@cluster.local
cluster metadata load took 233ms
1 components evaluated in 4ms

will synchronize 3 object(s)

Do you want to continue [y/n]: y
1 components evaluated in 5ms
create ingresses test-app -n default (source test-app)
create deployments test-app -n default (source test-app)
create services test-app -n default (source test-app)
server objects load took 440ms
---
stats:
  created:
  - ingresses test-app -n default (source test-app)
  - deployments test-app -n default (source test-app)
  - services test-app -n default (source test-app)

waiting for readiness of 1 objects
  - deployments test-app -n default

  0s    : deployments test-app -n default :: 0 of 1 updated replicas are available
✓ 1s    : deployments test-app -n default :: successfully rolled out (0 remaining)

✓ 1s: rollout complete
command took 3.6s

````   
Проверим доступность приложения по Http   
````  
➜  test-app git:(main) ✗ kubectl get ingress
NAME       CLASS   HOSTS                       ADDRESS          PORTS   AGE
test-app   nginx   test-app.tomaev-maksim.ru   158.160.56.126   80      82s

````   
![Снимок экрана 2024-02-06 в 09 50 44](https://github.com/tomaevmax/devops-netology/assets/32243921/656e483d-409b-4e7f-bece-c816d4814975)

</details>    


---
### Установка и настройка CI/CD

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:

1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
2. Автоматический деплой нового docker образа.

Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/), [GitLab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/) или GitHub Actions.

Ожидаемый результат:

1. Интерфейс ci/cd сервиса доступен по http.
2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.
3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистри, а также деплой соответствующего Docker образа в кластер Kubernetes.

<details>
<summary>Решение</summary>
<br>  

Организовывать ci/cd будем на основе [Gitlab CI](https://docs.gitlab.com/16.8/charts/quickstart/index.html)   
Установку будем производить с помощью helm.
Лог установки :   

````  
➜  diplom git:(main) ✗ helm install gitlab gitlab/gitlab \                                                                          
  --set global.hosts.domain=tomaev-maksim.ru \
  --set certmanager-issuer.email=tomaevmax@gmail.com
NAME: gitlab
LAST DEPLOYED: Thu Feb  8 08:01:19 2024
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
=== CRITICAL
The following charts are included for evaluation purposes only. They will not be supported by GitLab Support
for production workloads. Use Cloud Native Hybrid deployments for production. For more information visit
https://docs.gitlab.com/charts/installation/index.html#use-the-reference-architectures.
- PostgreSQL
- Redis
- Gitaly
- MinIO

=== NOTICE
The minimum required version of PostgreSQL is now 13. See https://gitlab.com/gitlab-org/charts/gitlab/-/blob/master/doc/installation/upgrade.md for more details.

=== NOTICE
You've installed GitLab Runner without the ability to use 'docker in docker'.
The GitLab Runner chart (gitlab/gitlab-runner) is deployed without the `privileged` flag by default for security purposes. This can be changed by setting `gitlab-runner.runners.privileged` to `true`. Before doing so, please read the GitLab Runner chart's documentation on why we
chose not to enable this by default. See https://docs.gitlab.com/runner/install/kubernetes.html#running-docker-in-docker-containers-with-gitlab-runners
Help us improve the installation experience, let us know how we did with a 1 minute survey:https://gitlab.fra1.qualtrics.com/jfe/form/SV_6kVqZANThUQ1bZb?installation=helm&release=16-8

````   
Ждем некоторое время до полного разворачивания подов.
Проверяем в соответствии с инструкцией готовность ингресс.

````   
➜  diplom git:(main) ✗ kubectl get ingress -lrelease=gitlab
NAME                        CLASS          HOSTS                       ADDRESS         PORTS     AGE
gitlab-kas                  gitlab-nginx   kas.tomaev-maksim.ru        158.160.39.35   80, 443   6m9s
gitlab-minio                gitlab-nginx   minio.tomaev-maksim.ru      158.160.39.35   80, 443   6m9s
gitlab-registry             gitlab-nginx   registry.tomaev-maksim.ru   158.160.39.35   80, 443   6m9s
gitlab-webservice-default   gitlab-nginx   gitlab.tomaev-maksim.ru     158.160.39.35   80, 443   6m9s

````   
Получем токен от root для первичной авторизации для этого воспользуемся командой:
````
kubectl get secret gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo   

```` 
Авторизуемся и импортируем репозитарий нашего тестового приложения с GitHub.   

![Снимок экрана 2024-02-08 в 09 25 35](https://github.com/tomaevmax/devops-netology/assets/32243921/7b123fea-a471-4b25-8355-f3fc813e4a39)

</details>    

Настраиваем  [.gitlab-ci.yml](sss) под согласно заданию. 


---
## Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.
2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud или вашего CI-CD-terraform pipeline.
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.
5. Репозиторий с конфигурацией Kubernetes кластера.
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.
7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)
