
// this file has the baseline default parameters
{
  components: {
    testapp: {
      name: 'test-app',
      image: 'tomaevmax/test-app:1.0.0',
      replicas: 1,
      containerPort: 80,
      servicePort: 80,
      nodeSelector: {},
      tolerations: [],
      ingressClass: 'nginx',
      domain: 'test-app.tomaev-maksim.ru',
    },
  },
}