echo "=====k9s settings======="
mkdir -p /tmp/k9s
cd /tmp/k9s
K9S_VERSION=v0.32.7
curl -sL https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz | sudo tar xfz - -C /usr/local/bin k9s

export KUBECONFIG=/root/.kube/config
echo 'export KUBECONFIG=/root/.kube/config' >> ~/.bashrc
source ~/.bashrc; k9s