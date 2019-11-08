Install openldap pkgs:
  pkg.installed:
    - pkgs:
      - openldap-servers
      - openldap-clients

Update to latest selinux-policy:
  pkg.installed:
    - name: selinux-policy

Enable http port in selinux:
  cmd.run:
    - name: setsebool httpd_can_network_connect true -P
    - onlyif: salt['grains.get']('selinux:enabled')

Install certs:
  pkg.installed:
    - sources:
      - stx-s3-certs: /opt/seagate/stx-s3-certs-1.0-1_s3dev.x86_64.rpm
      - stx-s3-client-certs: /opt/seagate/stx-s3-client-certs-1.0-1_s3dev.x86_64.rpm

Backup ldap config file:
  file.copy:
    - name: /etc/openldap/ldap.conf.bak
    - source: /etc/openldap/ldap.conf
    - force: True
    - preserve: True

Backup slapd config file:
  file.copy:
    - name: /etc/sysconfig/slapd.bak
    - source: /etc/sysconfig/slapd
    - force: True
    - preserve: True

Clean up old mdb ldiff file:
  file.absent:
    - name: /etc/openldap/slapd.d/cn=config/olcDatabase={2}mdb.ldif

Generate Slapdpasswds:
   cmd.run:
     - name: /opt/seagate/generated_configs/ldap/ldap_gen_passwd.sh

Copy mdb ldiff file, if not present:
  file.copy:
    - name: /etc/openldap/slapd.d/cn=config/olcDatabase={2}mdb.ldif
    - source: /opt/seagate/generated_configs/ldap/olcDatabase={2}mdb.ldif
    - force: True
    - user: ldap
    - group: ldap
    - require:
      - Generate Slapdpasswds
    - watch_in:
      - service: slapd

slapd:
  service.running:
    - enable: True
