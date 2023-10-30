
```bash
cat ignition.yml | butane | python -m json.tool > provision.ign

packer build -force ./flatcar-lts.pkr.hcl
```