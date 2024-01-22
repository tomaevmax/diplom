resource "local_file" "project" {
  content  = <<-DOC
all:
  hosts:
    node1:
      ansible_host: ${yandex_compute_instance_group.k8s-node.instances[0].network_interface[0].nat_ip_address}
      ip: ${yandex_compute_instance_group.k8s-node.instances[0].network_interface[0].ip_address}
      access_ip: ${yandex_compute_instance_group.k8s-node.instances[0].network_interface[0].ip_address}
    node2:
      ansible_host: ${yandex_compute_instance_group.k8s-node.instances[1].network_interface[0].nat_ip_address}
      ip: ${yandex_compute_instance_group.k8s-node.instances[1].network_interface[0].ip_address}
      access_ip: ${yandex_compute_instance_group.k8s-node.instances[1].network_interface[0].ip_address}
    node3:
      ansible_host: ${yandex_compute_instance_group.k8s-node.instances[2].network_interface[0].nat_ip_address}
      ip: ${yandex_compute_instance_group.k8s-node.instances[2].network_interface[0].ip_address}
      access_ip: ${yandex_compute_instance_group.k8s-node.instances[2].network_interface[0].ip_address}
  children:
    kube_control_plane:
      hosts:
        node1:
    kube_node:
      hosts:
        node1:
        node2:
        node3:
    etcd:
      hosts:
        node1:
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}
    DOC
  filename = "inventory/hosts.yaml"
}

# docker run --rm -it --mount type=bind,source="${HOME}"/.ssh/id_ed25519,dst=/root/.ssh/id_rsa --mount type=bind,source="${PWD}"/inventory/hosts.yaml,dst=/kubespray/inventory/my/hosts.yaml quay.io/kubespray/kubespray:v2.23.1 bash
