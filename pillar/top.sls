# So in an ideal world we would have everything in the pillar stack:
#
# https://docs.saltstack.com/en/latest/ref/pillar/all/salt.pillar.stack.html
#
# we need the minion ID pillar here already as the role is here assigned
# and pillar stack can not access values set inside the stack
#
# Once we have solved the problem with information from:
#
# ```
# minions/\{\{ minion_id \}\}.yml
# ```
#
# being available in stacks/config.cfg for the roles loop
#

{%- set cfgmgmt_basedir = '/srv/cfgmgmt' %}

{%- set minion_id = grains.id.replace('.', '_') %}
{%- set minion_pillar_path = cfgmgmt_basedir ~ '/pillar/minions/' ~ minion_id ~ '.sls' %}
{%- set minion_data = salt['slsutil.renderer'](path=minion_pillar_path) %}

base:
   '*':
      - profile-base
      - common
      {%- if 'salt_cluster' in minion_data %}
      - salt_cluster.{{ minion_data.salt_cluster }}
      {%- endif %}
      {%- if 'domain' in minion_data %}
      - domains.{{ minion_data.domain.replace('.', '_') }}
      {%- endif %}
      {%- if 'roles' in minion_data %}
      {%- for role in minion_data.roles %}
      - roles.{{ role }}
      {%- endfor %}
      {%- endif %}
      # minion specific overrides
      - minions.{{ minion_id }}
