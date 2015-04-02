{% set use_hardware = salt['config.get']('opencrowbar:use_hardware', True) %}
{% set use_develop = salt['config.get']('opencrowbar:use_develop', False) %}
{% set with_download = salt['config.get']('opencrowbar:with_download', False) %}

iptables:
  service.dead

permissive:
  selinux.mode

ocb-repo:
  pkgrepo.managed:
{% if use_develop == True %}
    - humanname: develop repo for opencrowbar RPMs
    - baseurl: http://opencrowbar.s3-website-us-east-1.amazonaws.com/develop
{% else %}
    - humanname: master repo for opencrowbar RPMs
    - baseurl: http://opencrowbar.s3-website-us-east-1.amazonaws.com/el6
{% endif %}
    - enabled: 1
    - gpgcheck: 0
    - type: none
    - autorefresh: 1
    - keeppackages: 1

{% if use_hardware == True %}
opencrowbar-hardware:
{% else %}
opencrowbar-core:
{% endif %}
  pkg.installed:
    - require:
      - pkgrepo: ocb-repo

/tftpboot/isos:
  file.directory:
    - makedirs: True

{% if with_download == True %}
centos_download:
  file.managed:
    - name: /tftpboot/isos/CentOS-7-x86_64-DVD-1503.iso
    - source: http://mirrors.kernel.org/centos/7/isos/x86_64/CentOS-7-x86_64-DVD-1503.iso
    - source_hash: md5=99e450fb1b22d2e528757653fcbf5fdc
    - require:
      - file: /tftpboot/isos
{% endif %}

{% if use_hardware == True %}
/tftpboot/files/raid:
  file.directory:
    - makedirs: True
{% endif %}
